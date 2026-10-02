import SwiftUI
import ServiceManagement
import UserNotifications

#if !CHECK
@main
struct UnbindApp: App {
    @State private var w = Watcher()
    var body: some Scene {
        MenuBarExtra {
            ContentView(w: w)
        } label: {
            // 비어 있음 = 뽑힌 플러그, 사용 중 = 꽂힌 플러그 + 개수
            Image(nsImage: templateImage(w.busy > 0 ? "menubar-busy" : "menubar-free"))
            if w.busy > 0 { Text("\(w.busy)") }
        }
        .menuBarExtraStyle(.window)

        Window("Unbind 설정", id: "settings") { SettingsView(w: w) }
            .windowResizability(.contentSize)
            .defaultLaunchBehavior(.suppressed)
    }
}
#endif

func templateImage(_ name: String) -> NSImage {
    let img = NSImage(named: name) ?? NSImage()
    img.isTemplate = true
    return img
}

struct Proc: Identifiable { let pid: Int32; let name: String; var protos: [String]; var container: String? = nil; var id: Int32 { pid } }
struct Info { let cmd: String; let cwd: String; let start: Date }

struct Config: Codable {
    var ports: [Int] = []
    var labels: [Int: String] = [:]
    var groups: [Int: String] = [:]
    var autoKill: Set<Int> = []
    var interval = 2.0
    var notify = true
}

// MARK: - 조회

func run(_ path: String, _ args: [String]) -> String {
    let t = Process(), pipe = Pipe()
    t.executableURL = URL(fileURLWithPath: path)
    t.arguments = args
    t.environment = ProcessInfo.processInfo.environment.merging(["LC_ALL": "C"]) { $1 }
    t.standardOutput = pipe
    t.standardError = FileHandle.nullDevice
    guard (try? t.run()) != nil else { return "" }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    t.waitUntilExit()
    return String(decoding: data, as: UTF8.self)
}

// lsof -F 출력(p<pid>, c<name>, P<proto>, n<addr>)을 포트별로 묶음
func parse(_ out: String) -> [Int: [Proc]] {
    var res: [Int: [Proc]] = [:], pid: Int32 = 0, name = "", proto = ""
    for line in out.split(separator: "\n") {
        let v = String(line.dropFirst())
        switch line.first {
        case "p": pid = Int32(v) ?? 0
        case "c": name = v
        case "P": proto = v
        case "n":
            // 로컬 주소 기준: "*:3000", "[::1]:3000", "a:3000->b:5000"
            let local = v.components(separatedBy: "->")[0]
            guard let port = Int(local.split(separator: ":").last ?? "") else { break }
            var procs = res[port, default: []]
            if let i = procs.firstIndex(where: { $0.pid == pid }) {
                if !procs[i].protos.contains(proto) { procs[i].protos.append(proto) }
            } else { procs.append(Proc(pid: pid, name: name, protos: [proto])) }
            res[port] = procs
        default: break
        }
    }
    return res
}

// 열린 포트 전체를 lsof 한 번으로 조회. TCP는 LISTEN만
func listeners() -> [Int: [Proc]] {
    parse(run("/usr/sbin/lsof", ["-nP", "-iTCP", "-sTCP:LISTEN", "-iUDP", "-FpcPn"]))
}

// ps "pid lstart command" 한 줄 → (pid, 시작시각, 명령어)
func parsePs(_ line: Substring) -> (Int32, Date, String)? {
    let t = line.split(separator: " ", maxSplits: 6)
    guard t.count == 7, let pid = Int32(t[0]) else { return nil }
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "EEE MMM d HH:mm:ss yyyy"
    return (pid, f.date(from: t[1...5].joined(separator: " ")) ?? Date(), t[6].trimmingCharacters(in: .whitespaces))
}

func infos(_ pids: [Int32]) -> [Int32: Info] {
    guard !pids.isEmpty else { return [:] }
    let list = pids.map(String.init).joined(separator: ",")
    var cwd: [Int32: String] = [:], pid: Int32 = 0
    for l in run("/usr/sbin/lsof", ["-a", "-d", "cwd", "-nP", "-Fn", "-p", list]).split(separator: "\n") {
        if l.first == "p" { pid = Int32(l.dropFirst()) ?? 0 } else if l.first == "n" { cwd[pid] = String(l.dropFirst()) }
    }
    var res: [Int32: Info] = [:]
    for l in run("/bin/ps", ["-o", "pid=,lstart=,command=", "-p", list]).split(separator: "\n") {
        if let (p, start, cmd) = parsePs(l) { res[p] = Info(cmd: cmd, cwd: cwd[p] ?? "", start: start) }
    }
    return res
}

let dockerBin = ["/usr/local/bin/docker", "/opt/homebrew/bin/docker", NSHomeDirectory() + "/.orbstack/bin/docker",
                 "/Applications/Docker.app/Contents/Resources/bin/docker"].first(where: FileManager.default.isExecutableFile)

// docker ps "이름\t0.0.0.0:9092-9093->9092-9093/tcp, ..." → 호스트 포트별 컨테이너
func parseDocker(_ out: String) -> [Int: String] {
    var res: [Int: String] = [:]
    for l in out.split(separator: "\n") {
        let parts = l.split(separator: "\t", maxSplits: 1)
        guard parts.count == 2 else { continue }
        for m in parts[1].components(separatedBy: ", ") where m.contains("->") {
            let b = (m.components(separatedBy: "->")[0].split(separator: ":").last ?? "").split(separator: "-").compactMap { Int($0) }
            guard let lo = b.first, let hi = b.last, lo <= hi else { continue }
            for p in lo...hi { res[p] = String(parts[0]) }
        }
    }
    return res
}

func isDocker(_ p: Proc) -> Bool { p.name.hasPrefix("com.docker") }

// MARK: - 알림

func notify(_ body: String) {
    let c = UNMutableNotificationContent()
    c.title = "Unbind"
    c.body = body
    UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: c, trigger: nil))
}

// MARK: - 상태

@Observable final class Watcher {
    var cfg: Config {
        didSet {
            UserDefaults.standard.set(try? JSONEncoder().encode(cfg), forKey: "config")
            if cfg.interval != oldValue.interval { schedule() }
        }
    }
    var all: [Int: [Proc]] = [:]
    var info: [Int32: Info] = [:]
    var termed: Set<Int32> = []      // SIGTERM 보낸 pid → 다음엔 강제 종료
    var stopping: Set<String> = []   // docker stop 진행 중
    var error = ""
    var sudoPid: Int32?              // 권한 없어 실패한 pid
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var lastBusy: [Int: Bool] = [:]

    var busy: Int { cfg.ports.filter { !(all[$0] ?? []).isEmpty }.count }

    init() {
        let d = UserDefaults.standard
        if let data = d.data(forKey: "config"), let c = try? JSONDecoder().decode(Config.self, from: data) {
            cfg = c
        } else {
            // 이전 버전의 ports 값 이어받기
            cfg = Config(ports: d.array(forKey: "ports") as? [Int] ?? (d.string(forKey: "ports") ?? "").split(separator: ",").compactMap { Int($0) })
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        schedule()
        refresh()
    }

    func schedule() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: cfg.interval, repeats: true) { [weak self] _ in self?.refresh() }
    }

    func refresh() {
        let known = Set(info.keys)
        DispatchQueue.global().async {
            var r = listeners()
            // ponytail: Docker가 포트를 잡고 있을 때만 docker ps 호출
            if let d = dockerBin, r.values.joined().contains(where: isDocker) {
                for (port, name) in parseDocker(run(d, ["ps", "--format", "{{.Names}}\t{{.Ports}}"])) {
                    r[port] = r[port]?.map { var p = $0; if isDocker(p) { p.container = name }; return p }
                }
            }
            let newInfo = infos(Array(Set(r.values.joined().map(\.pid)).subtracting(known)))
            DispatchQueue.main.async { self.apply(r, newInfo) }
        }
    }

    private func apply(_ r: [Int: [Proc]], _ newInfo: [Int32: Info]) {
        all = r
        let procs = r.values.joined()
        let live = Set(procs.map(\.pid))
        info = info.merging(newInfo) { $1 }.filter { live.contains($0.key) }
        termed.formIntersection(live)
        stopping.formIntersection(procs.compactMap(\.container))

        for port in cfg.ports {
            let now = r[port]?.first
            if cfg.notify, let was = lastBusy[port], was != (now != nil) {
                notify(now.map { String(localized: "\(title(port)) 사용 시작 · \($0.container ?? $0.name)") } ?? String(localized: "\(title(port)) 비었어요"))
            }
            lastBusy[port] = now != nil
            if cfg.autoKill.contains(port) {
                for p in r[port] ?? [] {
                    if !termed.contains(p.pid), p.container.map({ !stopping.contains($0) }) ?? true, cfg.notify {
                        notify(String(localized: "\(title(port)) 자동 종료 · \(p.container ?? p.name)"))
                    }
                    kill(p)
                }
            }
        }
    }

    func title(_ port: Int) -> String { cfg.labels[port].map { "\($0)(:\(port))" } ?? ":\(port)" }

    func add(_ input: String) -> Bool {
        let new = input.split(whereSeparator: { ", ".contains($0) }).compactMap { Int($0) }
        guard !new.isEmpty, new.allSatisfy({ (1...65535).contains($0) }) else { error = String(localized: "1~65535 사이 포트를 입력하세요"); return false }
        cfg.ports = Array(Set(cfg.ports + new)).sorted()
        error = ""
        refresh()
        return true
    }

    func remove(_ port: Int) {
        cfg.ports.removeAll { $0 == port }
        cfg.labels[port] = nil
        cfg.groups[port] = nil
        cfg.autoKill.remove(port)
        lastBusy[port] = nil
    }

    func kill(_ p: Proc) {
        if let c = p.container {
            guard let d = dockerBin, !stopping.contains(c) else { return }
            stopping.insert(c)
            DispatchQueue.global().async { _ = run(d, ["stop", c]); DispatchQueue.main.async { self.refresh() } }
            return
        }
        guard !isDocker(p) else { error = String(localized: "Docker 내부 프로세스는 종료할 수 없어요"); return }
        let force = termed.contains(p.pid)
        if Darwin.kill(p.pid, force ? SIGKILL : SIGTERM) != 0 {
            if errno == EPERM { sudoPid = p.pid; error = String(localized: "권한 없음: \(p.name)") } else { error = String(cString: strerror(errno)) }
            return
        }
        termed.insert(p.pid)
        error = ""
        sudoPid = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.refresh() }
    }

    func sudoKill() {
        guard let pid = sudoPid else { return }
        let sig = termed.contains(pid) ? 9 : 15
        var err: NSDictionary?
        NSAppleScript(source: "do shell script \"kill -\(sig) \(pid)\" with administrator privileges")?.executeAndReturnError(&err)
        if err != nil { error = String(localized: "관리자 권한 종료가 취소됐거나 실패했어요"); return }
        termed.insert(pid)
        error = ""
        sudoPid = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.refresh() }
    }
}

// MARK: - UI

let elapsedFmt: DateComponentsFormatter = {
    let f = DateComponentsFormatter()
    f.unitsStyle = .abbreviated
    f.maximumUnitCount = 2
    f.allowedUnits = [.day, .hour, .minute, .second]
    var cal = Calendar.current
    cal.locale = Locale(identifier: Bundle.main.preferredLocalizations.first ?? "en")
    f.calendar = cal
    return f
}()

struct ContentView: View {
    @Bindable var w: Watcher
    @State private var input = ""
    @State private var editing = false
    @State private var listHeight: CGFloat = 0
    @Environment(\.openWindow) private var openWindow

    var groups: [(String, [Int])] {
        Dictionary(grouping: w.cfg.ports) { w.cfg.groups[$0] ?? "" }.sorted { $0.key < $1.key }.map { ($0.key, $0.value.sorted()) }
    }
    var others: [Int] { w.all.keys.filter { !w.cfg.ports.contains($0) && w.all[$0]!.contains { $0.protos.contains("TCP") } }.sorted() }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("포트 추가 (예: 3000, 8080)", text: $input)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { if w.add(input) { input = "" } }
                Button("추가") { if w.add(input) { input = "" } }.disabled(input.isEmpty)
                Button { editing.toggle() } label: { Image(systemName: editing ? "checkmark" : "pencil") }
                    .help(editing ? "편집 완료" : "라벨·그룹·자동 종료 편집")
            }
            if !w.error.isEmpty {
                HStack {
                    Label(w.error, systemImage: "exclamationmark.triangle").font(.caption).foregroundStyle(.red)
                    if w.sudoPid != nil { Button("관리자 권한으로 종료") { w.sudoKill() }.controlSize(.small) }
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if w.cfg.ports.isEmpty {
                        Text("감시할 포트를 추가하세요").font(.callout).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                    }
                    ForEach(groups, id: \.0) { group, ports in
                        if !group.isEmpty { groupHeader(group, ports) }
                        ForEach(ports, id: \.self) { portRow($0) }
                    }
                    if !others.isEmpty {
                        DisclosureGroup("다른 열린 포트 (\(others.count))") {
                            ForEach(others, id: \.self) { otherRow($0) }
                        }
                        .font(.callout)
                    }
                }
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { listHeight = $0 }
            }
            .frame(height: min(listHeight, 440))

            Divider()
            HStack {
                Button {
                    openWindow(id: "settings")
                    NSApp.activate(ignoringOtherApps: true)
                } label: { Label("설정", systemImage: "gearshape") }
                Spacer()
                Button("앱 종료") { NSApp.terminate(nil) }.keyboardShortcut("q")
            }
            .font(.callout)
        }
        .padding()
        .frame(width: 360)
        .onAppear { w.refresh() }
    }

    func groupHeader(_ group: String, _ ports: [Int]) -> some View {
        let procs = ports.flatMap { w.all[$0] ?? [] }
        return HStack {
            Text(group).font(.caption.bold()).foregroundStyle(.secondary)
            Spacer()
            if !procs.isEmpty {
                Button("모두 종료", role: .destructive) { procs.forEach(w.kill) }.controlSize(.small).tint(.orange)
            }
        }
        .padding(.top, 4)
    }

    func portRow(_ port: Int) -> some View {
        let procs = w.all[port] ?? []
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle().fill(procs.isEmpty ? Color.secondary.opacity(0.4) : .green).frame(width: 8, height: 8)
                Text(verbatim: ":\(port)").font(.body.monospacedDigit()).bold()
                if let label = w.cfg.labels[port], !editing { Text(label) }
                if !editing { Text(procs.isEmpty ? "비어 있음" : "사용 중").font(.caption).foregroundStyle(.secondary) }
                Spacer()
                if w.cfg.autoKill.contains(port) { Image(systemName: "bolt.fill").foregroundStyle(.orange).help("자동 종료 켜짐") }
                Button { w.remove(port) } label: { Image(systemName: "xmark.circle.fill") }
                    .buttonStyle(.borderless).foregroundStyle(.secondary).help("감시 해제")
            }
            if editing {
                HStack {
                    TextField("라벨", text: Binding(get: { w.cfg.labels[port] ?? "" }, set: { w.cfg.labels[port] = $0.isEmpty ? nil : $0 }))
                    TextField("그룹", text: Binding(get: { w.cfg.groups[port] ?? "" }, set: { w.cfg.groups[port] = $0.isEmpty ? nil : $0 }))
                    Toggle("자동 종료", isOn: Binding(get: { w.cfg.autoKill.contains(port) }, set: { on in
                        if on { w.cfg.autoKill.insert(port) } else { w.cfg.autoKill.remove(port) }
                    }))
                    .toggleStyle(.checkbox)
                    .help("이 포트를 잡는 프로세스를 자동으로 종료")
                }
                .textFieldStyle(.roundedBorder)
                .font(.caption)
                .padding(.leading, 16)
            }
            ForEach(procs) { procRow($0) }
        }
    }

    func procRow(_ p: Proc) -> some View {
        let force = w.termed.contains(p.pid)
        let i = w.info[p.pid]
        let detail = [
            p.container == nil ? "PID \(p.pid)" : "Docker",
            p.protos.joined(separator: "/"),
            i.map { URL(fileURLWithPath: $0.cwd).lastPathComponent }.flatMap { $0.isEmpty || $0 == "/" ? nil : $0 },
            i.flatMap { elapsedFmt.string(from: $0.start, to: Date()) },
        ].compactMap { $0 }.joined(separator: " · ")
        return HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(p.container ?? p.name).lineLimit(1).truncationMode(.middle)
                Text(detail).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            .help(i.map { "\($0.cmd)\n\n📁 \($0.cwd)" } ?? p.name)
            Spacer()
            if let c = p.container {
                Button(w.stopping.contains(c) ? "중지 중…" : "컨테이너 중지", role: .destructive) { w.kill(p) }
                    .tint(.orange).disabled(w.stopping.contains(c))
            } else if !isDocker(p) {
                Button(force ? "강제 종료" : "종료", role: .destructive) { w.kill(p) }
                    .tint(force ? .red : .orange)
                    .help(force ? "SIGKILL: 즉시 강제 종료" : "SIGTERM: 정상 종료 요청")
            }
        }
        .padding(.leading, 16)
    }

    func otherRow(_ port: Int) -> some View {
        let p = w.all[port]![0]
        return HStack {
            Text(verbatim: ":\(port)").font(.callout.monospacedDigit())
            Text(p.container ?? p.name).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                .help(w.info[p.pid]?.cmd ?? p.name)
            Spacer()
            Button { _ = w.add(String(port)) } label: { Image(systemName: "plus.circle") }
                .buttonStyle(.borderless).help("감시 목록에 추가")
        }
    }
}

// 예: "1.0.0 (202610011855)"
let appVersion: String = {
    let i = Bundle.main.infoDictionary ?? [:]
    return "\(i["CFBundleShortVersionString"] as? String ?? "?") (\(i["CFBundleVersion"] as? String ?? "?"))"
}()

struct SettingsView: View {
    @Bindable var w: Watcher
    @State private var login = SMAppService.mainApp.status == .enabled
    @State private var loginError = ""

    var body: some View {
        Form {
            Picker("조회 주기", selection: $w.cfg.interval) {
                ForEach([1.0, 2, 5, 10], id: \.self) { Text("\(Int($0))초").tag($0) }
            }
            Toggle("포트 변화 알림", isOn: $w.cfg.notify)
            Toggle("로그인 시 실행", isOn: Binding(get: { login }, set: { on in
                do { try on ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister(); login = on; loginError = "" }
                catch { loginError = String(localized: "설정 실패: \(error.localizedDescription)") }
            }))
            if !loginError.isEmpty { Text(loginError).font(.caption).foregroundStyle(.red) }
            LabeledContent("버전", value: appVersion)
        }
        .formStyle(.grouped)
        .frame(width: 340)
    }
}

#if CHECK
@main
struct Check {
    static func main() {
        let r = parse("p1\ncA\nf3\nPUDP\nn*:3000\nf4\nPTCP\nn[::1]:3000\nf5\nPTCP\nn*:8080\np2\ncB\nf1\nPUDP\nn10.0.0.1:9000->1.1.1.1:3000\nf2\nPUDP\nn*:*\n")
        assert(r[3000]!.count == 1 && r[3000]![0].protos == ["UDP", "TCP"])
        assert(r[8080]![0].name == "A" && r[9000]![0].pid == 2 && r.count == 3)

        let ps = parsePs("98063 Thu Oct  1 18:07:59 2026     /bin/zsh -c echo  hi")!
        assert(ps.0 == 98063 && ps.2 == "/bin/zsh -c echo  hi" && Calendar.current.component(.hour, from: ps.1) == 18)

        let d = parseDocker("web\t0.0.0.0:8080->80/tcp, [::]:8080->80/tcp\nkafka\t0.0.0.0:9092-9093->9092-9093/tcp\nnoport\t\n")
        assert(d == [8080: "web", 9092: "kafka", 9093: "kafka"])
        print("check ok")
    }
}
#endif
