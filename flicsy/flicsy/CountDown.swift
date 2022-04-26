//
//  CountDown.swift
//  flicsy
//
//  Created by Esmeralda Nava on 4/25/22.
//

import SwiftUI
import UIKit


struct CountDown: View {
    @State var timeRemaining = 24*60*60
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("Next Reveal in...")
        Text("\(timeString(time: timeRemaining))")
                    .font(.system(size: 60))
                    .frame(height: 80.0)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(.blue)
                    .onReceive(timer){ _ in
                        if self.timeRemaining > 0 {
                            self.timeRemaining -= 1
                        }else{
                            self.timer.upstream.connect().cancel()
                        }
                    }
    }
    
    //Convert the time into 24hr (24:00:00) format
    func timeString(time: Int) -> String {
        let hours   = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

struct CountDown_Previews: PreviewProvider {
    static var previews: some View {
        CountDown()
    }
}
