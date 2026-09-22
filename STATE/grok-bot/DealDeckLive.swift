// Deal Deck — iOS/mobile client of blbestate.com Deal Deck (same product, not a separate deck).
// Founder locks 2026-09-22 (~11:15–11:19 ET):
//  • Live API only. Never invent deals, photos, or sample decks.
//  • Photos NOT in API schema → gold-ink placeholder + category glyph only (no Look Around / satellite / stock).
//  • Public-preview masking for owner/mailing; hide near-you when location is null/denied.
//  • Guest browse live deals; soft "Keep this deal?" on save — no Explore/sample path on Deal Deck.
//  • Identity: "Swipe the property — not a spreadsheet." Gold #c9a35f on ink.
import SwiftUI
import CoreLocation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Corpus

enum DealDeckCorpus {
    static let liveStates = ["AZ", "CA", "FL", "NJ", "NY", "TX"]
    static let phoenix = CLLocationCoordinate2D(latitude: 33.4484, longitude: -112.074)
    static let miles: Double = 3
    static let shortlistKey = "blbe_deck_shortlist_v1"
}

// MARK: - Card

struct DealDeckCard: Identifiable, Hashable {
    var id: String
    var state: String?
    var county: String?
    var parcelID: String?
    var ownerDisplay: String?
    var situsAddress: String?
    var situsCity: String?
    var situsZip: String?
    var mailingDisplay: String?
    var absentee: Bool
    var assessedValue: Double?
    var distanceMiles: Double?
    var basis: String?
    var gapEstimate: Double?
    var offer: Double?
    var spread: Double?
    var categoryGlyph: String
    var categoryLabel: String
    var hasBuilders: Bool

    var placeLine: String {
        [situsCity, county, state].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")
    }
}

// MARK: - Client (web scan projection first)

enum DealDeckClient {
    struct ScanJSON: Decodable {
        var note: String?
        var results: [Row]?
        struct Row: Decodable {
            var id: String?
            var state: String?
            var county: String?
            var parcel_id: String?
            var owner_masked: String?
            var situs_address: String?
            var situs_city: String?
            var situs_zip: String?
            var mailing_masked: String?
            var absentee: Bool?
            var assessed_value: Double?
            var distance_miles: Double?
            var basis: String?
            var gap_estimate: Double?
            var sample: Bool?
            var is_sample: Bool?
            var demo: Bool?
            var filler: Bool?
            var source: String?
            var builders: [String]?
            var area_builders: [String]?
        }
    }

    static func load(origin: CLLocationCoordinate2D, miles: Double, nearYou: Bool) async -> (cards: [DealDeckCard], note: String?, error: String?) {
        do {
            var c = URLComponents(string: "https://blbestate.com/api/index/scan")!
            c.queryItems = [
                URLQueryItem(name: "lat", value: String(origin.latitude)),
                URLQueryItem(name: "lng", value: String(origin.longitude)),
                URLQueryItem(name: "miles", value: String(miles))
            ]
            let (data, resp) = try await URLSession.shared.data(from: c.url!)
            guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            let env = try JSONDecoder().decode(ScanJSON.self, from: data)
            let cards = (env.results ?? []).compactMap { mapRow($0, nearYou: nearYou) }
            return (cards, env.note, nil)
        } catch {
            return ([], nil, error.localizedDescription)
        }
    }

    private static func mapRow(_ row: ScanJSON.Row, nearYou: Bool) -> DealDeckCard? {
        if row.sample == true || row.is_sample == true || row.demo == true || row.filler == true { return nil }
        if (row.source ?? "").lowercased() == "sample" { return nil }
        let id = row.id ?? row.parcel_id ?? ""
        guard !id.isEmpty else { return nil }
        let abs = row.absentee == true
        let (glyph, label) = category(row.basis, abs)
        return DealDeckCard(
            id: id,
            state: row.state,
            county: row.county,
            parcelID: row.parcel_id,
            ownerDisplay: nz(row.owner_masked),
            situsAddress: nz(row.situs_address),
            situsCity: nz(row.situs_city),
            situsZip: nz(row.situs_zip),
            mailingDisplay: nz(row.mailing_masked),
            absentee: abs,
            assessedValue: row.assessed_value,
            distanceMiles: nearYou ? row.distance_miles : nil,
            basis: row.basis,
            gapEstimate: row.gap_estimate,
            offer: nil,
            spread: nil,
            categoryGlyph: glyph,
            categoryLabel: label,
            hasBuilders: !((row.builders ?? row.area_builders ?? []).isEmpty)
        )
    }

    private static func nz(_ s: String?) -> String? {
        guard let s = s?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }
        return s
    }

    private static func category(_ basis: String?, _ absentee: Bool) -> (String, String) {
        let b = (basis ?? "").lowercased()
        if b.contains("teardown") || b.contains("land") { return ("hammer.fill", "Teardown") }
        if b.contains("probate") { return ("doc.text.fill", "Probate") }
        if absentee { return ("airplane", "Absentee") }
        if b.contains("below") || b.contains("discount") { return ("arrow.down.right.circle.fill", "Discount") }
        return ("building.2.fill", "Parcel")
    }
}

// MARK: - Shortlist + soft gate

enum DealDeckShortlist {
    static func load() -> [[String: Any]] {
        guard let data = UserDefaults.standard.data(forKey: DealDeckCorpus.shortlistKey),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return [] }
        return arr
    }

    static func push(_ card: DealDeckCard) {
        var list = load().filter { ($0["id"] as? String) != card.id }
        list.insert([
            "id": card.id,
            "parcel_id": card.parcelID as Any,
            "situs_address": card.situsAddress as Any,
            "situs_city": card.situsCity as Any,
            "state": card.state as Any,
            "county": card.county as Any,
            "assessed_value": card.assessedValue as Any,
            "basis": card.basis as Any,
            "saved_at": ISO8601DateFormatter().string(from: Date())
        ], at: 0)
        if let data = try? JSONSerialization.data(withJSONObject: Array(list.prefix(200))) {
            UserDefaults.standard.set(data, forKey: DealDeckCorpus.shortlistKey)
        }
    }
}

// MARK: - View model

@MainActor
final class DealDeckModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var cards: [DealDeckCard] = []
    @Published var index: Int = 0
    @Published var status: String = ""
    @Published var note: String?
    @Published var busy = false
    @Published var nearYou = false
    @Published var originLabel = "Phoenix, AZ · 3 mi"
    @Published var showKeepGate = false
    @Published var gateAddress = ""
    @Published var mailCopied = false

    private let location = CLLocationManager()
    private var origin = DealDeckCorpus.phoenix

    var current: DealDeckCard? {
        guard cards.indices.contains(index) else { return nil }
        return cards[index]
    }

    func start() {
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyKilometer
        Task { await refresh(origin: DealDeckCorpus.phoenix, nearYou: false, label: "Phoenix, AZ") }
        requestLocationIfAllowed()
    }

    func requestLocationIfAllowed() {
        switch location.authorizationStatus {
        case .notDetermined:
            location.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            location.requestLocation()
        default:
            break
        }
    }

    func pass() {
        index = min(index + 1, cards.count)
        status = "Passed"
    }

    func keep(signedIn: Bool) {
        guard let card = current else { return }
        DealDeckShortlist.push(card)
        gateAddress = card.situsAddress ?? "This parcel"
        index = min(index + 1, cards.count)
        status = "Kept on this device"
        if !signedIn { showKeepGate = true }
    }

    func copyMailing(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
        mailCopied = true
        status = "Mailing copied"
    }

    private func refresh(origin: CLLocationCoordinate2D, nearYou: Bool, label: String) async {
        busy = true
        status = "Loading live deals…"
        self.origin = origin
        self.nearYou = nearYou
        originLabel = label + " · \(Int(DealDeckCorpus.miles)) mi" + (nearYou ? " · near you" : "")
        let result = await DealDeckClient.load(origin: origin, miles: DealDeckCorpus.miles, nearYou: nearYou)
        cards = result.cards
        index = 0
        note = result.note
        if let err = result.error {
            status = err
        } else if cards.isEmpty {
            status = "No live deals in this envelope"
        } else {
            status = nearYou ? "Showing deals near you" : "Live \(label) preview"
        }
        busy = false
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            await refresh(origin: loc.coordinate, nearYou: true, label: "Near you")
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Stay on Phoenix — honest default.
    }
}

// MARK: - Root view (Deal Deck product surface)

struct DealDeckLiveView: View {
    @StateObject private var deck = DealDeckModel()
    @EnvironmentObject private var session: Session
    var onContinueAccount: (() -> Void)? = nil
    var onOpenWorkQueue: (() -> Void)? = nil

    var body: some View {
        ZStack {
            BL.base.ignoresSafeArea()
            VStack(alignment: .leading, spacing: BLScale.gap(14)) {
                identityHeader
                metaRow
                if let note = deck.note, !note.isEmpty {
                    Text(note).font(BLFont.body(12, .medium)).foregroundColor(BLTheme.sub)
                }
                stage
                controls
                Text(deck.status)
                    .font(BLFont.mono(11, .medium))
                    .foregroundColor(BLTheme.sub)
                    .accessibilityIdentifier("bl.re.deck.status")
            }
            .padding(.horizontal, BLScale.gutter(20))
            .padding(.vertical, BLScale.gap(16))

            if deck.showKeepGate {
                keepGate
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { deck.start() }
        .accessibilityIdentifier("bl.re.deck.root")
    }

    private var identityHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("DEAL DECK")
                .font(BLFont.mono(10, .bold))
                .tracking(1.6)
                .foregroundColor(BLTheme.gold)
            Text("Swipe the property — not a spreadsheet.")
                .font(.blSystem(size: BLScale.isCompact ? 22 : 28, weight: .bold, design: .serif))
                .foregroundColor(BLTheme.text)
                .accessibilityIdentifier("bl.re.deck.identity")
            Text("Live public-records preview. Pass or keep real parcels near you.")
                .font(BLFont.body(13, .semibold))
                .foregroundColor(BLTheme.sub)
        }
    }

    private var metaRow: some View {
        HStack {
            Text(deck.originLabel)
                .font(BLFont.mono(11, .bold))
                .foregroundColor(BL.ink)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(BLTheme.goldGrad)
                .clipShape(Capsule())
            Spacer()
            if !deck.cards.isEmpty {
                let left = max(0, deck.cards.count - deck.index)
                Text("\(left) of \(deck.cards.count) live deals")
                    .font(BLFont.mono(11, .medium))
                    .foregroundColor(BLTheme.sub)
            }
        }
    }

    @ViewBuilder private var stage: some View {
        ZStack {
            if deck.busy && deck.cards.isEmpty {
                VStack(spacing: 10) {
                    ProgressView().tint(BLTheme.gold)
                    Text("Loading live deals…").font(BLFont.body(15, .semibold)).foregroundColor(BLTheme.text)
                    Text("Fetching the public index for this area.").font(BLFont.body(12, .medium)).foregroundColor(BLTheme.sub)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if deck.cards.isEmpty || deck.index >= deck.cards.count {
                VStack(spacing: 10) {
                    Image(systemName: "building.2").font(.system(size: 36)).foregroundColor(BLTheme.gold)
                    Text("No live deals here")
                        .font(.blSystem(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(BLTheme.text)
                    Text("Honest empty — searchable live states are AZ, CA, FL, NJ, NY, TX. Nothing invented.")
                        .font(BLFont.body(13, .medium))
                        .foregroundColor(BLTheme.sub)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("bl.re.deck.empty")
            } else if let card = deck.current {
                DealDeckCardView(card: card, nearYou: deck.nearYou, onCopyMail: { deck.copyMailing($0) }, onBuilders: onOpenWorkQueue)
                    .id(card.id)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: BLScale.isCompact ? 420 : 520)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button { deck.pass() } label: {
                Text("Pass").font(BLFont.body(15, .bold)).foregroundColor(BLTheme.text)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(BLTheme.bg2).clipShape(Capsule())
                    .overlay(Capsule().stroke(BLTheme.stroke, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("bl.re.deck.pass")

            Button {
                let signedIn = session.signedIn && session.email != "guest" && !session.demoMode
                deck.keep(signedIn: signedIn)
            } label: {
                Text("Keep").font(BLFont.body(15, .bold)).foregroundColor(BL.ink)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(BLTheme.goldGrad).clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("bl.re.deck.keep")
        }
    }

    private var keepGate: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
                .onTapGesture { deck.showKeepGate = false }
            VStack(alignment: .leading, spacing: 14) {
                Text("Keep this deal?")
                    .font(.blSystem(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(BLTheme.text)
                    .accessibilityIdentifier("bl.re.deck.keep-gate")
                Text("\(deck.gateAddress) is on your device shortlist. Sign in to keep it across devices — or keep browsing as a guest.")
                    .font(BLFont.body(13, .medium))
                    .foregroundColor(BLTheme.sub)
                HStack(spacing: 10) {
                    Button {
                        deck.showKeepGate = false
                        onContinueAccount?()
                    } label: {
                        Text("Continue to account")
                            .font(BLFont.body(14, .bold)).foregroundColor(BL.ink)
                            .frame(maxWidth: .infinity).frame(height: 44)
                            .background(BLTheme.goldGrad).clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    Button {
                        deck.showKeepGate = false
                    } label: {
                        Text("Keep browsing")
                            .font(BLFont.body(14, .bold)).foregroundColor(BLTheme.text)
                            .frame(maxWidth: .infinity).frame(height: 44)
                            .background(BLTheme.bg2).clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .background(BL.readingFill)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(BLTheme.gold.opacity(0.35), lineWidth: 1))
            .padding(24)
        }
    }
}

// MARK: - Card chrome

struct DealDeckCardView: View {
    let card: DealDeckCard
    let nearYou: Bool
    var onCopyMail: (String) -> Void
    var onBuilders: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            photoPlaceholder
            VStack(alignment: .leading, spacing: 8) {
                Text(card.situsAddress ?? "Address withheld")
                    .font(.blSystem(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(BLTheme.text)
                if !card.placeLine.isEmpty {
                    Text(card.placeLine).font(BLFont.body(12, .semibold)).foregroundColor(BLTheme.sub)
                }
                if let owner = card.ownerDisplay {
                    Text("Owner · \(owner)").font(BLFont.body(12, .medium)).foregroundColor(BLTheme.sub)
                }
                if let mail = card.mailingDisplay {
                    HStack {
                        Text("Mailing · \(mail)")
                            .font(BLFont.body(12, .medium))
                            .foregroundColor(BLTheme.sub)
                            .lineLimit(2)
                        Spacer()
                        Button("Copy") { onCopyMail(mail) }
                            .font(BLFont.body(12, .bold))
                            .foregroundColor(BLTheme.gold)
                            .accessibilityIdentifier("bl.re.deck.copy-mail")
                    }
                }
                if let gap = card.gapEstimate {
                    Text("Gap est. · \(money(gap))").font(BLFont.body(12, .medium)).foregroundColor(BLTheme.sub)
                }
                if card.hasBuilders {
                    Button {
                        onBuilders?()
                    } label: {
                        Text("Area Builders → work queue")
                            .font(BLFont.body(13, .bold))
                            .foregroundColor(BLTheme.gold)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("bl.re.deck.builders")
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BL.readingFill)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(BLTheme.gold.opacity(0.28), lineWidth: 1))
        .accessibilityIdentifier("bl.re.deck.card")
    }

    /// Intentional photo honesty: void + gold ink + category glyph. No stock / Look Around / satellite.
    private var photoPlaceholder: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [Color(hex: 0x0A0A0A), Color(hex: 0x141210)], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 10) {
                Image(systemName: card.categoryGlyph)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(BLTheme.goldGrad)
                Text(card.categoryLabel.uppercased())
                    .font(BLFont.mono(11, .bold))
                    .tracking(1.4)
                    .foregroundColor(BLTheme.gold)
                Text(card.parcelID.map { "Parcel \($0)" } ?? "Public parcel")
                    .font(BLFont.body(12, .semibold))
                    .foregroundColor(BLTheme.sub)
                Text("No listing photos in public preview")
                    .font(BLFont.body(11, .medium))
                    .foregroundColor(BLTheme.mute)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Page bars reserved for future real multi-photo — single stub bar so chrome matches brief without lying.
            HStack(spacing: 5) {
                Capsule().fill(BLTheme.gold).frame(width: 18, height: 3)
            }
            .padding(.top, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            chips
                .padding(12)
        }
        .frame(height: BLScale.isCompact ? 260 : 320)
        .accessibilityIdentifier("bl.re.deck.photo-placeholder")
    }

    private var chips: some View {
        FlowChips(items: chipItems)
    }

    private var chipItems: [ChipItem] {
        var items: [ChipItem] = []
        if nearYou, let d = card.distanceMiles {
            items.append(.init(text: String(format: d < 10 ? "%.2f mi" : "%.1f mi", d), gold: true))
        }
        if let a = card.assessedValue {
            items.append(.init(text: "\(money(a)) assessed", gold: false))
        }
        if let o = card.offer {
            items.append(.init(text: "Offer \(money(o))", gold: true))
        }
        if let s = card.spread {
            items.append(.init(text: "Spread \(money(s))", gold: true))
        }
        if let b = card.basis, !b.isEmpty {
            items.append(.init(text: b.replacingOccurrences(of: "-", with: " "), gold: true))
        }
        items.append(.init(text: card.categoryLabel, gold: false))
        if card.absentee { items.append(.init(text: "Absentee", gold: false, warn: true)) }
        if nearYou { items.append(.init(text: "Near you", gold: true)) }
        return items
    }

    private func money(_ n: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 0
        f.currencyCode = "USD"
        return f.string(from: NSNumber(value: n)) ?? "$\(Int(n))"
    }
}

private struct ChipItem: Hashable {
    var text: String
    var gold: Bool
    var warn: Bool = false
}

private struct FlowChips: View {
    let items: [ChipItem]
    var body: some View {
        FlexibleChipWrap(items: items)
    }
}

private struct FlexibleChipWrap: View {
    let items: [ChipItem]
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { item in
                        Text(item.text)
                            .font(BLFont.mono(10, .bold))
                            .foregroundColor(item.warn ? Color(hex: 0xFFB86B) : (item.gold ? BL.ink : BLTheme.text))
                            .padding(.horizontal, 8).padding(.vertical, 5)
                            .background(chipBg(item))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }


    @ViewBuilder private func chipBg(_ item: ChipItem) -> some View {
        if item.warn {
            Color(hex: 0xFFB86B).opacity(0.18)
        } else if item.gold {
            BLTheme.goldGrad
        } else {
            Color.black.opacity(0.45)
        }
    }

    private var rows: [[ChipItem]] {
        // Simple wrap: 3 per row.
        stride(from: 0, to: items.count, by: 3).map { Array(items[$0..<min($0 + 3, items.count)]) }
    }
}
