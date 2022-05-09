//
//  Subview.swift
//  App Onboarding
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI

struct Subview: View {
    
    var imageString: String
    
    var body: some View {
        Image(imageString)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .clipped()
    }
}

#if DEBUG
struct Subview_Previews: PreviewProvider {
    static var previews: some View {
        Subview(imageString: "meditating")
    }
}
#endif
