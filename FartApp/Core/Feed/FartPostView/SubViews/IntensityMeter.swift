//
//  IntensityMeter.swift
//  FartApp
//
//  Created by Amir Kabiri on 8/17/25.
//

import SwiftUI

struct IntensityMeter: View {
    let level: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Circle()
                    .fill(index <= level ? Color.yellow : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
}
#Preview {
    IntensityMeter(level: 2)
}
