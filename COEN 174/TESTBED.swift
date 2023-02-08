//
//  TESTBED.swift
//  COEN 174
//
//  Created by Gavin Ryder on 2/7/23.
//

import SwiftUI

struct TESTBED: View {
    var body: some View {
        VStack {
            HStack(spacing: -5) {
                Image(systemName: "laurel.leading")
                Image(systemName: "laurel.trailing")
            }
            .font(.system(size: 30))
            .foregroundColor(Color("Wheat"))
            
            Image(systemName: "leaf")
                .font(.system(size: 30))
                .foregroundColor(Color("Fern"))
        }
    }
}

struct TESTBED_Previews: PreviewProvider {
    static var previews: some View {
        TESTBED()
    }
}
