//
//  PopCornAnimation.swift
//  CineSwipe


import SwiftUI

struct PopCornAnimation: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let gravity: Double = 900
                let cycle: Double = 2.8

                // Construit une forme de popcorn = plusieurs cercles agglomérés
                func popcornPath(radius: CGFloat, seed: Int) -> Path {
                    var path = Path()
                    // Lobe central
                    path.addEllipse(in: CGRect(x: -radius * 0.9, y: -radius * 0.9,
                                               width: radius * 1.8, height: radius * 1.8))
                    // 5 lobes périphériques, tailles et positions variées selon le seed
                    let lobes = 5
                    for k in 0..<lobes {
                        let angle = (Double(k) / Double(lobes)) * .pi * 2
                               + Double((seed * 13 + k * 7) % 100) / 100.0
                        let dist  = radius * (0.75 + CGFloat((seed * 3 + k) % 20) / 60)
                        let lr    = radius * (0.7  + CGFloat((seed * 5 + k) % 25) / 50)
                        let cx = CGFloat(cos(angle)) * dist
                        let cy = CGFloat(sin(angle)) * dist
                        path.addEllipse(in: CGRect(x: cx - lr, y: cy - lr,
                                                   width: lr * 2, height: lr * 2))
                    }
                    return path
                }

                for i in 0..<60 {
                    let startX = (Double(i) * 73).truncatingRemainder(dividingBy: size.width)
                    let baseY  = size.height - 8

                    let offset = (Double(i) * 0.137).truncatingRemainder(dividingBy: cycle)
                    let local  = (t + offset).truncatingRemainder(dividingBy: cycle)

                    let popDelay = 0.6 + Double(i % 7) * 0.05

                    // Phase "pop" : trajectoire balistique
                    let tp = local - popDelay
                    let vx = (Double((i * 17) % 200) - 100)
                    let vy = -(420 + Double((i * 31) % 180))
                    let x  = startX + vx * tp
                    let y  = baseY + vy * tp + 0.5 * gravity * tp * tp
                    guard y < size.height + 20 else { continue }

                    // Rotation propre + taille du popcorn
                    let rotation = Angle.radians(tp * Double((i % 5) + 1) * 1.8
                                                 + Double(i))
                    let popFlash = max(0, 1 - tp * 6)
                    let baseR: CGFloat = (i % 5 == 0) ? 6 : 4.5
                    let r = baseR + CGFloat(popFlash) * 2

                    // Halo blanc au moment de l'éclatement
                    if popFlash > 0.1 {
                        let halo = CGRect(x: x - r * 2.2, y: y - r * 2.2,
                                          width: r * 4.4, height: r * 4.4)
                        ctx.fill(Path(ellipseIn: halo),
                                 with: .color(.white.opacity(0.22 * popFlash)))
                    }

                    // Dessin du popcorn dans un contexte transformé (translation + rotation)
                    ctx.drawLayer { layer in
                        layer.translateBy(x: x, y: y)
                        layer.rotate(by: rotation)

                        let shape = popcornPath(radius: r, seed: i)

                        // Ombre légère pour donner du relief
                        layer.fill(shape.offsetBy(dx: 0.6, dy: 0.8),
                                   with: .color(.black.opacity(0.18)))

                        // Corps du popcorn : crème / blanc cassé
                        let body = Color(red: 1.0, green: 0.96, blue: 0.82)
                        layer.fill(shape, with: .color(body))

                        // Highlight pour le côté "soufflé"
                        let highlight = popcornPath(radius: r * 0.55, seed: i + 99)
                            .offsetBy(dx: -r * 0.25, dy: -r * 0.3)
                        layer.fill(highlight, with: .color(.white.opacity(0.55)))
                    }
                }
            }
        }
    }
}

#Preview {
    PopCornAnimation()
}
