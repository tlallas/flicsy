//
//  SkipView.swift
//  flicsy
//
//  Created by Taylor  Lallas on 5/14/22.
//

import Foundation
import SwiftUI

struct SkipView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var isPresented: Bool
    @Binding var revealed : Bool
    @Binding var submitted : Bool
    @Binding var alreadySkipped : Bool
    @FetchRequest(entity: RevealController.entity(),
                  sortDescriptors: [])
    var revealController : FetchedResults<RevealController>
    
    
    struct IdentifiableString: Identifiable, Hashable {
        let string: String
        var id: String { string }
    }
    @State var selected: Set<IdentifiableString> = Set([].map { IdentifiableString(string: $0) })
    
  
  var body: some View {
      VStack(alignment: .leading) {
          HStack {
              Spacer()
              Button(action: {
                isPresented = false
              }, label: {
                Text("Cancel")
              })
          }.padding([.trailing, .top])
          
          VStack (alignment: .leading) {
              Text("Want to skip this photo?")
                  .font(.title)
                  .fontWeight(.bold)
                  .padding([.top])
                  .padding(.bottom, 3)
                  .foregroundColor(Color("PrimaryColor"))
                  
              Text("You can skip one photo each day.")
                  .font(.headline)
                  .foregroundColor(Color("PrimaryColor"))
                  .padding(.bottom, 3)
              Text("Please tell us why you're skipping this photo, so that we can improve Flicsy.")
                  .font(.subheadline)
                  .foregroundColor(Color("PrimaryColor"))
                  .padding(.bottom)
          }.padding(.leading)
          
          VStack {
              MultiSelectionView(
                  options: ["It is a junk photo", "I don't want to see photos of this place", "I don't want to see photos from this time", "I don't want to see photos with this person/people", "Other"].map { IdentifiableString(string: $0) },
                  optionToString: { $0.string },
                  selected: $selected
              ).frame(maxHeight: 300)
              
              HStack {
                  Spacer()
                  Button(action: {
                      revealed = false
                      submitted = false
                      //FIRST use
                      if revealController.isEmpty {
                          let controller = RevealController(context: managedObjectContext)
                          controller.nextReveal = nil
                          controller.lastSkip = Date()
                          PersistenceController.shared.save()
                          
                      }
                      //UPDATE existing revealController
                      for controller in revealController {
                          controller.nextReveal = nil
                          controller.lastSkip = Date()
                          PersistenceController.shared.save()
                      }
                      isPresented = false
                      alreadySkipped = true
                  }, label: {
                      Text("Skip Photo")
                          .padding()
                          .background(Color("BabyBlueColor"))
                          .foregroundColor(Color("PrimaryColor"))
                          .cornerRadius(12)
                  })
                  Spacer()
              }
              Spacer()
          }
          
      }
  }
}


struct MultiSelectionView<Selectable: Identifiable & Hashable>: View {
    let options: [Selectable]
    let optionToString: (Selectable) -> String

    @Binding
    var selected: Set<Selectable>
    
    var body: some View {
        VStack {
            List {
                ForEach(options) { selectable in
                    Button(action: { toggleSelection(selectable: selectable) }) {
                        HStack {
                            Text(optionToString(selectable)).foregroundColor(.black)

                            Spacer()

                            if selected.contains { $0.id == selectable.id } {
                                Image(systemName: "checkmark").foregroundColor(.accentColor)
                            }
                        }
                    }.tag(selectable.id)
                }
            }.listStyle(PlainListStyle())
        }
    }

    private func toggleSelection(selectable: Selectable) {
        if let existingIndex = selected.firstIndex(where: { $0.id == selectable.id }) {
            selected.remove(at: existingIndex)
        } else {
            selected.insert(selectable)
        }
    }
}
