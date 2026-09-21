//
//  DateFormat.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

extension Date {
    /// La date telle que l'écrivent les maquettes : « 21 fev 2026 ».
    ///
    /// Le format court du système donne « 21 févr. 2026 » — accent et point
    /// compris. Les abréviations sont donc posées à la main, faute de quoi la
    /// pastille de 91 points de large déborderait sur les mois longs.
    var forumBadge: String {
        let months = ["jan", "fev", "mar", "avr", "mai", "juin",
                      "juil", "aout", "sept", "oct", "nov", "dec"]
        var calendar = Calendar(identifier: .gregorian)
        // Les dates arrivent du serveur en UTC : les lire dans le fuseau local
        // ferait basculer d'un jour les posts écrits en soirée.
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt

        let parts = calendar.dateComponents([.day, .month, .year], from: self)
        guard let day = parts.day, let month = parts.month, let year = parts.year else {
            return ""
        }
        return "\(day) \(months[month - 1]) \(year)"
    }
}
