//
//  AppDelegate.swift
//  Atari800Mac
//
//  Created by Rod Münch on 19/12/2017.
//  Copyright © 2017 Atari800 development team. All rights reserved.
//

import Cocoa
import Atari800EmulationCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var terminationReply: NSApplication.TerminateReply?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    
        if let emulator = Atari800Emulator.shared() {
         
            emulator.delegate = self
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        guard let emulator = Atari800Emulator.shared() else {
            
            return .terminateNow
        }
        
        if let result = terminationReply {
            
            return result
        }
        
        emulator.stopEmulation { (ok, error) in
            
            self.terminationReply = .terminateNow
            sender.terminate(self)
        }
        
        terminationReply = .terminateLater
        
        return terminationReply!
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    
        let url = URL(fileURLWithPath: filename)
        
        if let emulator = Atari800Emulator.shared() {
            
            DispatchQueue.main.async {
                
                emulator.loadFile(url) { (ok, error) in
                    
                    NSDocumentController.shared.noteNewRecentDocumentURL(url)
                }
            }
        }

        return true;
    }
}

extension AppDelegate: Atari800EmulatorDelegate {
    
    func emulator(_ emulator: Atari800Emulator!, didSelectCartridgeWithPossibleTypes types: [NSNumber : String]!, filename: String!, completion: Atari800CartridgeSelectionHandler!) {
        
        if let keyWindow = NSApplication.shared.keyWindow {
            
            if let emulationViewController = keyWindow.contentViewController as? EmulationViewController {
                
                emulationViewController.cartridgeDetails = CartridgeDetails(fileName: filename, types: types, completion: completion)
                
                emulationViewController.performSegue(withIdentifier: EmulationViewController.ShowCartridgeTypesSegue, sender: self)
            }
        }
    }
}

