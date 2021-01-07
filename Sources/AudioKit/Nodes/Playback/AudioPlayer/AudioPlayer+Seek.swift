//
//  File.swift
//  
//
//  Created by Jeffrey Blayney on 1/6/21.
//

import AVFoundation

// Extension for seeking to a specific AVAudioTime
public extension AudioPlayer {

    /// Play the audio player from a specific time
    /// - Parameters:
    ///   - time: The time at which the player will seek to
    func seek(time: Double) {
        elapsedTimeOffset = time

        if isBuffered {
            Log("Seeking a buffer is not yet supported :(", type: .error)
            return

        } else if let file = file {
            let playLength: Double = duration - time
            let startFrame = AVAudioFramePosition(sampleRate * time)
            let frameLength = AVAudioFrameCount(sampleRate * playLength)

            if playLength <= 0 {
                return
            }

            isPaused = true
            playerNode.stop()
            playerNode.scheduleSegment(file,
                                       startingFrame: startFrame,
                                       frameCount: frameLength,
                                       at: nil,
                                       completionCallbackType: .dataPlayedBack) { _ in
                self.internalCompletionHandler()
            }
            playerNode.play()
            isPlaying = true
            isPaused = false
        } else {
            Log("The player needs a file or a valid buffer to seek", type: .error)
        }
    }
}
