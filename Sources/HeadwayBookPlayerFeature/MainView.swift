//
//  ContentView.swift
//  Headway_Test
//
//  Created by Robert Koval on 20.11.2023.
//

import SwiftUI
import ComposableArchitecture

public struct MainView: View {
    public let store: StoreOf<BookPlayerFeature>

    public init(store: StoreOf<BookPlayerFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { screen in
                VStack {
                    ZStack {
                        BookCover(imageName: viewStore.book.coverImageName)
                            .opacity(viewStore.isChapterListOpen ? 0 : 1)
                            .offset(x: viewStore.isChapterListOpen ? -screen.size.width : 0)
                        
                        List {
                            ForEach(viewStore.loadedChapters, id: \.id) { chapter in
                                ChapterRow(track: chapter, isSelected: viewStore.currentChapter?.id == chapter.id) { id in
                                    store.send(.selectChapterButtonTapped(id))
                                }
                            }
                        }
                        .listStyle(.plain)
                        .opacity(viewStore.isChapterListOpen ? 1 : 0)
                        .offset(x: viewStore.isChapterListOpen ? 0 : screen.size.width)
                    }
                    .frame(maxHeight: screen.size.height * 0.5)
                    .animation(.easeInOut, value: viewStore.isChapterListOpen)
                    
                    TrackDescription(chapter: viewStore.currentChapter, numberOfChapters: viewStore.numberOfChapters)
                    
                    if let track = viewStore.currentChapter  {
                        HStack {
                            timeTitle(viewStore.currentTime).foregroundStyle(Color.hwGraySecondary)
                            PlayerProgressBar(value: viewStore.binding(get: \.playbackProgress, send: { .rewind($0) }))
                            timeTitle(track.duration).foregroundStyle(Color.hwGraySecondary)
                        }
                        .padding(.vertical)
                    } else {
                        HStack {
                            Text("--:--")
                            PlayerProgressBar(value: .constant(0))
                            Text("--:--")
                        }
                        .padding(.vertical)
                        .redacted(reason: .placeholder)
                    }
                    
                    Button {
                        viewStore.send(.playbackRateButtonTapped)
                    } label: {
                        Text("Speed \(viewStore.playbackSpeed.description)").fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(Color.black)
                    
                    Spacer()
                    HStack(spacing: 16) {
                        PlayerButton(imageName: "backward.end.fill", imageSize: .init(width: 32, height: 32)) {
                            store.send(.playPreviousButtonTapped)
                        }
                        
                        PlayerButton(imageName: "gobackward.5", imageSize: .init(width: 40, height: 40)) {
                            store.send(.goBackward5ButtonTapped)
                        }
                        
                        PlayerButton(imageName: viewStore.isPlaying ? "pause.fill" : "play.fill", imageSize: .init(width: 44, height: 44)) {
                            if viewStore.isPlaying {
                                store.send(.pauseButtonTapped)
                            } else {
                                store.send(.playButtonTapped)
                            }
                            
                        }
                        
                        PlayerButton(imageName: "goforward.10", imageSize: .init(width: 40, height: 40)) {
                            store.send(.goForward10ButtonTapped)
                        }
                        
                        PlayerButton(imageName: "forward.end.fill", imageSize: .init(width: 32, height: 32)) {
                            store.send(.playNextButtonTapped)
                        }
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                    
                    PageSwitch(isToggled: viewStore.binding(get: \.isChapterListOpen, send: .chapterListSwitchToggled),
                               leftIcon: Image(systemName: "headphones"),
                               rightIcon: Image(systemName: "text.alignright"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color.hwBackground)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onDisappear {
                viewStore.send(.onDisappear)
            }
        }
        .alert(store: store.scope(state: \.$alert, action: { childAction in
                .alertConfirmButtonTapped
        }))
    }
    
    func timeTitle(_ time: String) -> some View {
        Text(time).font(.custom("Spot Mono Regular", size: 17, relativeTo: .body))
    }
}

//#Preview {
//    MainView(store: .init(initialState: BookPlayerFeature.State(book: ), reducer: {
//        BookPlayerFeature()
//            ._printChanges()
//    }))
//}
