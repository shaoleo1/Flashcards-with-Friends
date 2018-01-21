//
//  MessagesViewController.swift
//  Flashcards With Friends MessagesExtension
//
//  Created by Leo Shao on 1/19/18.
//  Copyright © 2018 Leo Shao. All rights reserved.
//

import Foundation
import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController, UISearchBarDelegate, UITextFieldDelegate {
    
    
    // Outlets of the screen elements such as buttons, text boxes, search bars, and labels. These are variables connected to the storyboard that we can use to access these elements on the screen.
    @IBOutlet weak var searchBox: UISearchBar!
    @IBOutlet weak var buttonSetOne: UIButton!
    @IBOutlet weak var buttonSetTwo: UIButton!
    @IBOutlet weak var buttonSetThree: UIButton!
    @IBOutlet weak var buttonSetFour: UIButton!
    @IBOutlet weak var buttonSetFive: UIButton!
    @IBOutlet weak var buttonSetSix: UIButton!
    @IBOutlet weak var buttonSetSeven: UIButton!
    @IBOutlet weak var buttonSetEight: UIButton!
    @IBOutlet weak var buttonSetNine: UIButton!
    @IBOutlet weak var buttonSetTen: UIButton!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var termTextBox: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var rightWrongResult: UILabel!
    @IBOutlet weak var myScoreLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var youLabel: UILabel!
    @IBOutlet weak var mcButton1: UIButton!
    @IBOutlet weak var mcButton2: UIButton!
    @IBOutlet weak var mcButton3: UIButton!
    @IBOutlet weak var mcButton4: UIButton!
    @IBOutlet weak var idkButton: UIButton!
    @IBOutlet weak var labelScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var unlockTimed: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    private var setTitle = ""
    private var setAuthor = ""
    private var term_count = 0
    private var setID = 0
    private var currentTermDefinition = ""
    private var numberCorrect = 0
    private var opponentNumberCorrect = 0
    private var questionNumber = 1
    private var opponentLastCorrect: Bool?
    private var originalSender: UUID? = nil
    private var timer: Int = 0
    
    private var seconds: Int = 0
    
    private var gameTimer = Timer()
    
    // Declares an array of the study set IDs, titles, authors, and term counts corresponding to the appropriate buttons for looping.
    var buttonSetIDs = [Int?](repeating: nil, count: 10)
    var buttonSetTitles = [String?](repeating: nil, count: 10)
    var buttonSetAuthors = [String?](repeating: nil, count: 10)
    var buttonSetTermCounts = [Int?](repeating: nil, count: 10)
    
    var mcCorrectButton = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        IAPService.shared.getProducts()
        
        searchBox.delegate = self
        termTextBox.delegate = self
        
        termTextBox.returnKeyType = UIReturnKeyType.go
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        if let message = conversation.selectedMessage {
        if (message.senderParticipantIdentifier != conversation.localParticipantIdentifier && message.url != nil) {
            // Called when the extension is about to move from the inactive to active state.
            // This will happen when the extension is about to present UI.
            
            // Use this method to configure the extension and restore previously stored state.
            
            // If there is a selectedMessage (and we're not just launching the app to send a new quiz to someone), it will create a variable 'message' that represents the selected message.
                // Sets all the buttons and the search box to hidden since we aren't searching for a study set; we're playing a game.
                searchBox.isHidden = true
                buttonSetOne.isHidden = true
                buttonSetTwo.isHidden = true
                buttonSetThree.isHidden = true
                buttonSetFour.isHidden = true
                buttonSetFive.isHidden = true
                buttonSetSix.isHidden = true
                buttonSetSeven.isHidden = true
                buttonSetEight.isHidden = true
                buttonSetNine.isHidden = true
                buttonSetTen.isHidden = true
                
                // Creates a variable 'setID' that is the study set ID passed through the URL parameters of the message selected.
                let setID = getQueryStringParameter(url: (message.url?.absoluteString)!, param: "setID")
                // Creates a 'request' variable with the URL of the Quizlet API. Includes the set ID in the URL with the client id to gain access.
                var request = URLRequest(url: URL(string: "https://api.quizlet.com/2.0/sets/" + setID! + "?client_id=bFxdXkTKvW")!)
                // Sets the http method to GET which means GETting data FROM the API. There are two methods, GET and POST. POST means POSTing data TO the API. In this case, we're using GET.
                request.httpMethod = "GET"
                // Sets the file type that the data will be retrieved to be JSON, which is the standard format.
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Starts the HTTP session (connects to the API URL with the search query and GETs the data).
                let session = URLSession.shared
                let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                    do {
                        // Converts and saves the returned data into a variable called 'json' in appropriate JSON formatting.
                        let json = try JSONSerialization.jsonObject(with: data!, options: [])
                        // Creates a dictionary from the JSON file to look up the value for the key given.
                        if let dictionary = json as? [String: Any] {
                            // Creates an array of the returned terms.
                            if let nestedArray = dictionary["terms"] as? [Any] {
                                // Creates a dictionary of the current term details (e.g. term, definition, term number).
                                if let currentTerm = nestedArray[Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "questionNumber")!)! - 1] as? [String: Any] {
                                    // Looks up the term and saves it into the variable 'term'.
                                    if let term = currentTerm["term"] as? String {
                                        // Looks up the definition and saves it into the variable 'definition'.
                                        if let definition = currentTerm["definition"] as? String {
                                            self.setTitle = self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "setTitle")!
                                            self.setAuthor = self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "setAuthor")!
                                            self.term_count = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "term_count")!)!
                                            self.setID = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "setID")!)!
                                            self.currentTermDefinition = term
                                            self.numberCorrect = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "numberCorrect")!)!
                                            self.opponentNumberCorrect = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "opponentNumberCorrect")!)!
                                            self.questionNumber = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "questionNumber")!)!
                                            self.originalSender = UUID(uuidString: self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "originalSender")!)
                                            self.timer = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "timer")!)!
                                            if self.timer > 0 {
                                                self.seconds = self.timer
                                                self.timerLabel.text = String(self.timer)
                                                self.timerLabel.isHidden = false
                                            }
                                            // Uses the main thread--required for UI changes.
                                            guard let conversation = self.activeConversation else { fatalError("Expected a conversation.") }
                                            DispatchQueue.main.async {
                                                if definition == "" {
                                                    if let imageDict = currentTerm["image"] as? [String: Any] {
                                                        if let imageURL = imageDict["url"] as? String {
                                                            let session = URLSession(configuration: .default)
                                                            let downloadImageTask = session.dataTask(with: URL(string: imageURL)!) { (data, response, error) in
                                                                if let e = error {
                                                                    print("Error downloading image: \(e)")
                                                                } else {
                                                                    if let res = response as? HTTPURLResponse {
                                                                        print("Downloaded image with response code \(res.statusCode)")
                                                                        if let imageData = data {
                                                                            let image = UIImage(data: imageData)
                                                                            DispatchQueue.main.async {
                                                                                self.imageView.image = image
                                                                                self.imageView.isHidden = false
                                                                            }
                                                                        } else {
                                                                            print("Couldn't get image: Image is nil")
                                                                        }
                                                                    } else {
                                                                        print("Couldn't get response code")
                                                                    }
                                                                }
                                                            }
                                                            downloadImageTask.resume()
                                                        }
                                                    }
                                                } else {
                                                    self.definitionLabel.text = definition
                                                    self.definitionLabel.isHidden = false
                                                    self.labelScrollView.isHidden = false
                                                    self.labelScrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.definitionLabel.bottomAnchor).isActive = true
                                                }
                                                self.termTextBox.isHidden = false
                                                self.myScoreLabel.isHidden = false
                                                self.opponentScoreLabel.isHidden = false
                                                self.opponentLabel.isHidden = false
                                                self.youLabel.isHidden = false
                                                self.idkButton.isHidden = false
                                                self.progressBar.isHidden = false
                                                self.progressBar.progress = Float(self.questionNumber) / Float(self.term_count)
                                                if(self.originalSender == conversation.localParticipantIdentifier) {
                                                    self.myScoreLabel.text = String(self.numberCorrect)
                                                    self.opponentScoreLabel.text = String(self.opponentNumberCorrect)
                                                } else {
                                                    self.myScoreLabel.text = String(self.opponentNumberCorrect)
                                                    self.opponentScoreLabel.text = String(self.numberCorrect)
                                                }
                                                if self.timer > 0 {
                                                    self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(MessagesViewController.updateTimer)), userInfo: nil, repeats: true)
                                                }
                                            }
                                            // It will then iterate through the for loop again until all terms have been looped through.
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        print("error")
                    }
                })
                task.resume()
            }
        }
    }
    
    override func didResignActive(with conversation: MSConversation) {
        super.didResignActive(with: conversation)
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        super.didReceive(message, conversation: conversation)
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        super.didSelect(message, conversation: conversation)
        if(message.senderParticipantIdentifier != conversation.localParticipantIdentifier && message.url != nil) {
            // Sets all the buttons and the search box to hidden since we aren't searching for a study set; we're playing a game.
            searchBox.isHidden = true
            buttonSetOne.isHidden = true
            buttonSetTwo.isHidden = true
            buttonSetThree.isHidden = true
            buttonSetFour.isHidden = true
            buttonSetFive.isHidden = true
            buttonSetSix.isHidden = true
            buttonSetSeven.isHidden = true
            buttonSetEight.isHidden = true
            buttonSetNine.isHidden = true
            buttonSetTen.isHidden = true
            
            // Creates a variable 'setID' that is the study set ID passed through the URL parameters of the message selected.
            let setID = getQueryStringParameter(url: (message.url?.absoluteString)!, param: "setID")
            // Creates a 'request' variable with the URL of the Quizlet API. Includes the set ID in the URL with the client id to gain access.
            var request = URLRequest(url: URL(string: "https://api.quizlet.com/2.0/sets/" + setID! + "?client_id=bFxdXkTKvW")!)
            // Sets the http method to GET which means GETting data FROM the API. There are two methods, GET and POST. POST means POSTing data TO the API. In this case, we're using GET.
            request.httpMethod = "GET"
            // Sets the file type that the data will be retrieved to be JSON, which is the standard format.
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Starts the HTTP session (connects to the API URL with the search query and GETs the data).
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                    // Converts and saves the returned data into a variable called 'json' in appropriate JSON formatting.
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    // Creates a dictionary from the JSON file to look up the value for the key given.
                    if let dictionary = json as? [String: Any] {
                        // Creates an array of the returned terms.
                        if let nestedArray = dictionary["terms"] as? [Any] {
                            // Creates a dictionary of the current term details (e.g. term, definition, term number).
                            if let currentTerm = nestedArray[Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "questionNumber")!)! - 1] as? [String: Any] {
                                // Looks up the term and saves it into the variable 'term'.
                                if let term = currentTerm["term"] as? String {
                                    // Looks up the definition and saves it into the variable 'definition'.
                                    if let definition = currentTerm["definition"] as? String {
                                        self.setTitle = self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "setTitle")!
                                        self.setAuthor = self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "setAuthor")!
                                        self.term_count = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "term_count")!)!
                                        self.setID = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "setID")!)!
                                        self.currentTermDefinition = term
                                        self.numberCorrect = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "numberCorrect")!)!
                                        self.opponentNumberCorrect = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "opponentNumberCorrect")!)!
                                        self.questionNumber = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "questionNumber")!)!
                                        self.originalSender = UUID(uuidString: self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "originalSender")!)
                                        self.timer = Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "timer")!)!
                                        if self.timer > 0 {
                                            self.seconds = self.timer
                                            self.timerLabel.text = String(self.timer)
                                            self.timerLabel.isHidden = false
                                        }
                                        // Uses the main thread--required for UI changes.
                                        guard let conversation = self.activeConversation else { fatalError("Expected a conversation.") }
                                        DispatchQueue.main.async {
                                            if definition == "" {
                                                if let imageDict = currentTerm["image"] as? [String: Any] {
                                                    if let imageURL = imageDict["url"] as? String {
                                                        let session = URLSession(configuration: .default)
                                                        let downloadImageTask = session.dataTask(with: URL(string: imageURL)!) { (data, response, error) in
                                                            if let e = error {
                                                                print("Error downloading image: \(e)")
                                                            } else {
                                                                if let res = response as? HTTPURLResponse {
                                                                    print("Downloaded image with response code \(res.statusCode)")
                                                                    if let imageData = data {
                                                                        let image = UIImage(data: imageData)
                                                                        DispatchQueue.main.async {
                                                                            self.imageView.image = image
                                                                            self.imageView.isHidden = false
                                                                        }
                                                                    } else {
                                                                        print("Couldn't get image: Image is nil")
                                                                    }
                                                                } else {
                                                                    print("Couldn't get response code")
                                                                }
                                                            }
                                                        }
                                                        downloadImageTask.resume()
                                                    }
                                                }
                                            } else {
                                                self.definitionLabel.text = definition
                                                self.definitionLabel.isHidden = false
                                                self.labelScrollView.isHidden = false
                                                self.labelScrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.definitionLabel.bottomAnchor).isActive = true
                                            }
                                            self.termTextBox.isHidden = false
                                            self.myScoreLabel.isHidden = false
                                            self.opponentScoreLabel.isHidden = false
                                            self.opponentLabel.isHidden = false
                                            self.youLabel.isHidden = false
                                            self.idkButton.isHidden = false
                                            self.progressBar.isHidden = false
                                            self.progressBar.progress = Float(self.questionNumber) / Float(self.term_count)
                                            if(self.originalSender == conversation.localParticipantIdentifier) {
                                                self.myScoreLabel.text = String(self.numberCorrect)
                                                self.opponentScoreLabel.text = String(self.opponentNumberCorrect)
                                            } else {
                                                self.myScoreLabel.text = String(self.opponentNumberCorrect)
                                                self.opponentScoreLabel.text = String(self.numberCorrect)
                                            }
                                            if self.timer > 0 {
                                                self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(MessagesViewController.updateTimer)), userInfo: nil, repeats: true)
                                            }
                                        }
                                        // It will then iterate through the for loop again until all terms have been looped through.
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("error")
                }
            })
            task.resume()
        }
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        super.didStartSending(message, conversation: conversation)
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        super.didCancelSending(message, conversation: conversation)
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
        if conversation.selectedMessage != nil {
            conversation.sendText("Flashcards With Friends: I cheated by deleting the message!", completionHandler: {
                error -> Void in
            })
        }
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.willTransition(to: presentationStyle)
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        super.didTransition(to: presentationStyle)
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        if let message = conversation.selectedMessage {
            if message.senderParticipantIdentifier != conversation.localParticipantIdentifier && presentationStyle == .compact {
                conversation.sendText("Flashcards With Friends: I tried to cheat by closing out of the app!", completionHandler: {
                    error -> Void in
                })
            }
        }
    }
    
    // Function to get the URL query parameters from a URl string. Returns the first value found for the parameter key given.
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    // A struct is similar to a class except that it holds variables only. We use this to create Quiz structures/objects that group all the variables together rather than keeping them all separate.
    struct Quiz {
        let setTitle: String
        let setAuthor: String
        let term_count: Int
        let setID: Int
        var questionNumber: Int
        var numberCorrect: Int
        var opponentNumberCorrect: Int
        let originalSender: UUID
        let timer: Int
    }
    
    // Function to check if the user that selected the message is the same as the user that sent it. Returns a boolean.
    private func isSenderSameAsRecipient() -> Bool {
        guard let conversation = activeConversation else { return false }
        guard let message = conversation.selectedMessage else { return false }
        
        return message.senderParticipantIdentifier == conversation.localParticipantIdentifier
    }
    
    private func composeMessage(quiz: Quiz) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        let session = conversation.selectedMessage?.session ?? MSSession()
        if self.questionNumber - 1 != self.term_count || self.originalSender != conversation.localParticipantIdentifier {
            // Creates a variable 'session' with the selected message's session.
            var messageCaption = NSLocalizedString("Let's play a quiz game.", comment: "")
            if (opponentLastCorrect == true) {
                if self.definitionLabel.text == "" {
                    messageCaption = NSLocalizedString("I identified an image correctly.", comment: "")
                } else {
                    messageCaption = NSLocalizedString("I got '\(String(describing: self.definitionLabel.text!))' right.", comment: "")
                }
            } else if (opponentLastCorrect == false) {
                if self.definitionLabel.text == "" {
                    messageCaption = NSLocalizedString("I identified an image incorrectly.", comment: "")
                } else {
                    messageCaption = NSLocalizedString("I got '\(String(describing: self.definitionLabel.text!))' wrong.", comment: "")
                }
            }
            
            // Creates a variable 'layout' that is a MSMessageTemplateLayout object and sets its image, image title, caption, and subcaption.
            let layout = MSMessageTemplateLayout()
            if (self.opponentLastCorrect == nil) {
                layout.image = UIImage(named: "flashcardswf.png")
            } else if (self.opponentLastCorrect)!{
                layout.image = UIImage(named: "flashcardswfGreen.png")
            } else if (!self.opponentLastCorrect!) {
                layout.image = UIImage(named: "flashcardswfRed.png")
            }
            layout.imageTitle = "\(quiz.setTitle) by \(quiz.setAuthor)"
            layout.caption = messageCaption
            layout.subcaption = "\(quiz.term_count) terms"
            
            // Creates a variable 'components' that is a URLComponents object and creates a variable 'queryItems' with the key-value pairs for the URl query. Then it sets the component query items equal to that.
            var components = URLComponents()
            let queryItems = [URLQueryItem(name: "setTitle", value: quiz.setTitle), URLQueryItem(name: "setAuthor", value: quiz.setAuthor), URLQueryItem(name: "term_count", value: String(quiz.term_count)), URLQueryItem(name: "setID", value: String(quiz.setID)), URLQueryItem(name: "questionNumber", value: String(quiz.questionNumber)), URLQueryItem(name: "numberCorrect", value: String(quiz.numberCorrect)), URLQueryItem(name: "opponentNumberCorrect", value: String(quiz.opponentNumberCorrect)), URLQueryItem(name: "originalSender", value: String(describing: quiz.originalSender)), URLQueryItem(name: "timer", value: String(quiz.timer))]
            components.queryItems = queryItems
            
            // Creates a variable 'message' that is a MSMessage object and sets its layout and url to the variables we just created above as well as the summary text and accessibility label.
            let message = MSMessage(session: session)
            message.layout = layout
            message.url = components.url!
            message.summaryText = "Flashcards With Friends"
            message.accessibilityLabel = messageCaption
            
            // Tries to insert the message we just created into the user's message application to send. Throws an error if there's an error.
            conversation.send(message) { error in
                if let error = error {
                    print(error)
                }
            }
        } else {
            // Tries to create a variable 'conversation' that is equal to the active conversation. If it doesn't exist then it will throw an error.
            // Creates a variable 'session' with the selected message's session.
            let session = conversation.selectedMessage?.session ?? MSSession()
            var messageCaption = NSLocalizedString("", comment: "")
            if (self.numberCorrect > self.opponentNumberCorrect) {
                messageCaption = NSLocalizedString("I win \(self.numberCorrect)-\(self.opponentNumberCorrect)!", comment: "")
            } else if (self.numberCorrect < self.opponentNumberCorrect) {
                messageCaption = NSLocalizedString("You win \(self.opponentNumberCorrect)-\(self.numberCorrect)!", comment: "")
            } else {
                messageCaption = NSLocalizedString("We tied \(self.numberCorrect)-\(self.opponentNumberCorrect)!", comment: "")
            }
            
            // Creates a variable 'layout' that is a MSMessageTemplateLayout object and sets its image, image title, caption, and subcaption.
            let layout = MSMessageTemplateLayout()
            layout.image = UIImage(named: "flashcardswf.png")
            layout.imageTitle = "\(self.setTitle) by \(self.setAuthor)"
            layout.caption = messageCaption
            layout.subcaption = "\(self.term_count) terms"
            
            // Creates a variable 'message' that is a MSMessage object and sets its layout and url to the variables we just created above as well as the summary text and accessibility label.
            let message = MSMessage(session: session)
            message.layout = layout
            message.summaryText = "Flashcards With Friends"
            message.accessibilityLabel = messageCaption
            
            // Tries to insert the message we just created into the user's message application to send. Throws an error if there's an error.
            conversation.send(message) { error in
                if let error = error {
                    print(error)
                }
            }
        }
        
        dismiss()
    }

    @IBAction func setButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select a Gamemode", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Normal", comment: "Normal gamemode"), style: .default, handler: { _ in
            // Creates a Quiz structure containing all the data necessary.
            guard let conversation = self.activeConversation else { fatalError("Expected a conversation") }
            let quiz = Quiz(setTitle: self.buttonSetTitles[sender.tag - 1]!, setAuthor: self.buttonSetAuthors[sender.tag - 1]!, term_count: self.buttonSetTermCounts[sender.tag - 1]!, setID: self.buttonSetIDs[sender.tag - 1]!, questionNumber: 1, numberCorrect: 0, opponentNumberCorrect: 0, originalSender: conversation.localParticipantIdentifier, timer: 0)
            // Calls the composeMessage function with the 'quiz'.
            self.composeMessage(quiz: quiz)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Timed", comment: "Timed gamemode"), style: .default, handler: { _ in
            let alert = UIAlertController(title: "How Long?", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Timer length in seconds"
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: "Confirm"), style: .default, handler: { _ in
                if let time = Int((alert.textFields?.first?.text)!) {
                    guard let conversation = self.activeConversation else { fatalError("Expected a conversation") }
                    let quiz = Quiz(setTitle: self.buttonSetTitles[sender.tag - 1]!, setAuthor: self.buttonSetAuthors[sender.tag - 1]!, term_count: self.buttonSetTermCounts[sender.tag - 1]!, setID: self.buttonSetIDs[sender.tag - 1]!, questionNumber: 1, numberCorrect: 0, opponentNumberCorrect: 0, originalSender: conversation.localParticipantIdentifier, timer: time)
                    // Calls the composeMessage function with the 'quiz'.
                    self.composeMessage(quiz: quiz)
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        termTextBox.resignFirstResponder()
        termTextBox.isUserInteractionEnabled = false
        idkButton.isUserInteractionEnabled = false
        gameTimer.invalidate()
        timerLabel.isHidden = true
        
        guard let conversation = activeConversation else { return false }
        if(termTextBox.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == currentTermDefinition.lowercased()) {
            if(self.originalSender == conversation.localParticipantIdentifier) {
                numberCorrect += 2
                rightWrongResult.text = "Correct 🤑"
                myScoreLabel.text = String(numberCorrect)
            } else {
                opponentNumberCorrect += 2
                rightWrongResult.text = "Correct 🤑"
                myScoreLabel.text = String(opponentNumberCorrect)
            }
            rightWrongResult.textColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            opponentLastCorrect = true
        } else {
            if(self.originalSender == conversation.localParticipantIdentifier) {
                rightWrongResult.text = "Wrong 😤"
                myScoreLabel.text = String(numberCorrect)
            } else {
                rightWrongResult.text = "Wrong 😤"
                myScoreLabel.text = String(opponentNumberCorrect)
            }
            rightWrongResult.textColor = UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0)
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "\(termTextBox.text!) \(currentTermDefinition)")
            attributedString.setColorForText(textForAttribute: termTextBox.text!, withColor: UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0))
            attributedString.setColorForText(textForAttribute: currentTermDefinition, withColor: UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0))
            termTextBox.attributedText = attributedString
            if (termTextBox.intrinsicContentSize.width > self.termTextBox.bounds.width) {
                let alert = UIAlertController(title: "Correct Answer", message: currentTermDefinition, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
            }
            opponentLastCorrect = false
        }
        opponentScoreLabel.isHidden = false
        rightWrongResult.isHidden = false
        myScoreLabel.isHidden = false
        sendButton.isHidden = false
        
        return true
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        requestPresentationStyle(MSMessagesAppPresentationStyle.expanded)
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBox: UISearchBar)  {
        // Closes the keyboard
        searchBox.resignFirstResponder()
        // Calls the searchQuizlet() function
        searchQuizlet()
    }
    
    private func searchQuizlet() {
        // Creates an array of buttons in order from 1-10 for ordered iteration
        let buttons: [UIButton] = [self.buttonSetOne, self.buttonSetTwo, self.buttonSetThree, self.buttonSetFour, self.buttonSetFive, self.buttonSetSix, self.buttonSetSeven, self.buttonSetEight, self.buttonSetNine, self.buttonSetTen]
        
        // Creates a 'request' variable with the URL of the Quizlet API. Sets 'q' equal to the URL encoded search query. URL encoding simply replaces spaces in the search query with '%20' so it becomes a valid URL.
        var request = URLRequest(url: URL(string: "https://api.quizlet.com/2.0/search/sets?q=" + searchBox.text!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)! + "&per_page=10&client_id=bFxdXkTKvW")!) // per_page=10 limits the results to 10 only, client_id is a required value to gain authorization to access the data, it's a unique key given to us.
        // Sets the http method to GET which means GETting data FROM the API. There are two methods, GET and POST. POST means POSTing data TO the API. In this case, we're using GET.
        request.httpMethod = "GET"
        // Sets the file type that the data will be retrieved to be JSON, which is the standard format.
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Starts the HTTP session (connects to the API URL with the search query and GETs the data).
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                // Converts and saves the returned data into a variable called 'json' in appropriate JSON formatting.
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                // Creates a dictionary from the JSON file to look up the value for the key given.
                if let dictionary = json as? [String: Any] {
                    // Creates an array of the returned study sets.
                    if let nestedArray = dictionary["sets"] as? [Any] {
                        // Loops through every study set where 'object' is the name of the variable for the study set during that loop. It's the Java equivalent of an enhanced for loop--idk if you learned about it yet.
                        for (index, object) in nestedArray.enumerated() {
                            // Creates a dictionary from the given study set.
                            if let setDictionary = object as? [String: Any] {
                                // Looks up the title of the set and saves it into the variable 'title'.
                                if let title = setDictionary["title"] as? String {
                                    // Looks up the author of the set and saves it into the variable 'author'.
                                    if let author = setDictionary["created_by"] as? String {
                                        // Looks up the term count of the set and saves it into the variable 'term_count'.
                                        if let term_count = setDictionary["term_count"] as? Int {
                                            // Looks up the id of the set and saves it into the variable 'id'.
                                            if let id = setDictionary["id"] as? Int {
                                                // Saves the id into the appropriate index of the buttonSetIDs array.
                                                self.buttonSetIDs[index] = id
                                                self.buttonSetTitles[index] = title
                                                self.buttonSetAuthors[index] = author
                                                self.buttonSetTermCounts[index] = term_count
                                            }
                                            // Uses the main thread--required to make UI changes.
                                            DispatchQueue.main.async() {
                                                // Shows the button.
                                                buttons[index].isHidden = false
                                                // Sets the button text.
                                                buttons[index].setTitle("\(title) by \(author) - \(term_count) terms", for: .normal)
                                                self.buttonSetOne.layer.cornerRadius = 10
                                                self.buttonSetOne.layer.shadowOffset = CGSize(width: 5, height: 5)
                                                self.buttonSetOne.layer.shadowRadius = 5
                                                self.buttonSetOne.layer.shadowOpacity = 0.5
                                                self.buttonSetTwo.layer.cornerRadius = 10
                                                self.buttonSetTwo.layer.shadowOffset = CGSize(width: 5, height: 5)
                                                self.buttonSetTwo.layer.shadowRadius = 5
                                                self.buttonSetTwo.layer.shadowOpacity = 0.5
                                                self.buttonSetThree.layer.cornerRadius = 10
                                                self.buttonSetThree.layer.shadowOffset = CGSize(width: 5, height: 5)
                                                self.buttonSetThree.layer.shadowRadius = 5
                                                self.buttonSetThree.layer.shadowOpacity = 0.5
                                                self.buttonSetFour.layer.cornerRadius = 10
                                                self.buttonSetFour.layer.shadowOffset = CGSize(width: 5, height: 5)
                                                self.buttonSetFour.layer.shadowRadius = 5
                                                self.buttonSetFour.layer.shadowOpacity = 0.5
                                                self.buttonSetFive.layer.cornerRadius = 10
                                                self.buttonSetFive.layer.shadowOffset = CGSize(width: 5, height: 5)
                                                self.buttonSetFive.layer.shadowRadius = 5
                                                self.buttonSetFive.layer.shadowOpacity = 0.5
                                                self.buttonSetSix.layer.cornerRadius = 10
                                                self.buttonSetSix.layer.shadowOffset = CGSize(width: 5, height: 5)
                                                self.buttonSetSix.layer.shadowRadius = 5
                                                self.buttonSetSix.layer.shadowOpacity = 0.5
                                                self.buttonSetSeven.layer.cornerRadius = 10
                                                self.buttonSetSeven.layer.shadowOffset = CGSize(width: 5, height: 5)
                                                self.buttonSetSeven.layer.shadowRadius = 5
                                                self.buttonSetSeven.layer.shadowOpacity = 0.5
                                                self.buttonSetEight.layer.cornerRadius = 10
                                                self.buttonSetEight.layer.shadowOffset = CGSize(width: 5, height: 5)
                                                self.buttonSetEight.layer.shadowRadius = 5
                                                self.buttonSetEight.layer.shadowOpacity = 0.5
                                                self.buttonSetNine.layer.cornerRadius = 10
                                                self.buttonSetNine.layer.shadowOffset = CGSize(width: 5, height: 5)
                                                self.buttonSetNine.layer.shadowRadius = 5
                                                self.buttonSetNine.layer.shadowOpacity = 0.5
                                                self.buttonSetTen.layer.cornerRadius = 10
                                                self.buttonSetTen.layer.shadowOffset = CGSize(width: 5, height: 5)
                                                self.buttonSetTen.layer.shadowRadius = 5
                                                self.buttonSetTen.layer.shadowOpacity = 0.5
                                            }
                                            // It will then iterate through the for loop again until all objects have been looped through, which should be 10 times since we limited the results to a maximum of 10.
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    
    @IBAction func idkButtonPressed(_ sender: UIButton) {
        termTextBox.resignFirstResponder()
        mcButton1.isHidden = false
        mcButton2.isHidden = false
        mcButton3.isHidden = false
        mcButton4.isHidden = false
        termTextBox.isHidden = true
        idkButton.isHidden = true
        
        
        var request = URLRequest(url: URL(string: "https://api.quizlet.com/2.0/sets/" + String(self.setID) + "?client_id=bFxdXkTKvW")!)
        // Sets the http method to GET which means GETting data FROM the API. There are two methods, GET and POST. POST means POSTing data TO the API. In this case, we're using GET.
        request.httpMethod = "GET"
        // Sets the file type that the data will be retrieved to be JSON, which is the standard format.
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Starts the HTTP session (connects to the API URL with the search query and GETs the data).
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                // Converts and saves the returned data into a variable called 'json' in appropriate JSON formatting.
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                // Creates a dictionary from the JSON file to look up the value for the key given.
                if let dictionary = json as? [String: Any] {
                    // Creates an array of the returned terms.
                    if let nestedArray = dictionary["terms"] as? [Any] {
                        let term = nestedArray[self.questionNumber - 1] as? [String: Any]
                        let termTerm = term!["term"] as? String
                        // Creates a dictionary of the current term details (e.g. term, definition, term number).
                        
                        var pickedTermsArray = [Int?](repeating: nil, count: 3)
                        var pickedButtonsArray = [Int?](repeating: nil, count: 3)
                        for _ in 0...2 {
                            var randomTermIndex = arc4random_uniform(UInt32(self.term_count))
                            var randomButtonInt = arc4random_uniform(4)
                            DispatchQueue.main.sync {
                                while (pickedTermsArray.contains(where: { $0 == Int(randomTermIndex) }) || Int(randomTermIndex) == (self.questionNumber - 1)) {
                                    randomTermIndex = arc4random_uniform(UInt32(self.term_count))
                                }
                            }
                            DispatchQueue.main.sync {
                                while (pickedButtonsArray.contains(where: { $0 == Int(randomButtonInt) })) {
                                    randomButtonInt = arc4random_uniform(4)
                                }
                            }
                            DispatchQueue.main.sync {
                                if (randomButtonInt == 0) {
                                    let term = nestedArray[Int(randomTermIndex)] as? [String: Any]
                                    let termTerm = term!["term"] as? String
                                    self.mcButton1.setTitle(termTerm, for: .normal)
                                    self.mcButton1.titleLabel?.minimumScaleFactor = 0.6
                                    self.mcButton1.titleLabel?.numberOfLines = 3
                                    self.mcButton1.titleLabel?.adjustsFontSizeToFitWidth = true
                                    pickedTermsArray.append(Int(randomTermIndex))
                                    pickedButtonsArray.append(0)
                                } else if (randomButtonInt == 1) {
                                    let term = nestedArray[Int(randomTermIndex)] as? [String: Any]
                                    let termTerm = term!["term"] as? String
                                    self.mcButton2.setTitle(termTerm, for: .normal)
                                    self.mcButton2.titleLabel?.minimumScaleFactor = 0.6
                                    self.mcButton2.titleLabel?.numberOfLines = 3
                                    self.mcButton2.titleLabel?.adjustsFontSizeToFitWidth = true
                                    pickedTermsArray.append(Int(randomTermIndex))
                                    pickedButtonsArray.append(1)
                                } else if (randomButtonInt == 2) {
                                    let term = nestedArray[Int(randomTermIndex)] as? [String: Any]
                                    let termTerm = term!["term"] as? String
                                    self.mcButton3.setTitle(termTerm, for: .normal)
                                    self.mcButton3.titleLabel?.minimumScaleFactor = 0.6
                                    self.mcButton3.titleLabel?.numberOfLines = 3
                                    self.mcButton3.titleLabel?.adjustsFontSizeToFitWidth = true
                                    pickedTermsArray.append(Int(randomTermIndex))
                                    pickedButtonsArray.append(2)
                                } else if (randomButtonInt == 3) {
                                    let term = nestedArray[Int(randomTermIndex)] as? [String: Any]
                                    let termTerm = term!["term"] as? String
                                    self.mcButton4.setTitle(termTerm, for: .normal)
                                    self.mcButton4.titleLabel?.minimumScaleFactor = 0.6
                                    self.mcButton4.titleLabel?.numberOfLines = 3
                                    self.mcButton4.titleLabel?.adjustsFontSizeToFitWidth = true
                                    pickedTermsArray.append(Int(randomTermIndex))
                                    pickedButtonsArray.append(3)
                                }
                            }
                        }
                        DispatchQueue.main.sync {
                            if (!pickedButtonsArray.contains(where: { $0 == 0 })) {
                                self.mcButton1.setTitle(termTerm, for: .normal)
                                self.mcButton1.titleLabel?.minimumScaleFactor = 0.5
                                self.mcButton1.titleLabel?.numberOfLines = 3
                                self.mcButton1.titleLabel?.adjustsFontSizeToFitWidth = true
                                self.mcCorrectButton = 0
                            } else if (!pickedButtonsArray.contains(where: { $0 == 1 })) {
                                self.mcButton2.setTitle(termTerm, for: .normal)
                                self.mcButton2.titleLabel?.minimumScaleFactor = 0.5
                                self.mcButton2.titleLabel?.numberOfLines = 3
                                self.mcButton2.titleLabel?.adjustsFontSizeToFitWidth = true
                                self.mcCorrectButton = 1
                            } else if (!pickedButtonsArray.contains(where: { $0 == 2 })) {
                                self.mcButton3.setTitle(termTerm, for: .normal)
                                self.mcButton3.titleLabel?.minimumScaleFactor = 0.5
                                self.mcButton3.titleLabel?.numberOfLines = 3
                                self.mcButton3.titleLabel?.adjustsFontSizeToFitWidth = true
                                self.mcCorrectButton = 2
                            } else if (!pickedButtonsArray.contains(where: { $0 == 3 })) {
                                self.mcButton4.setTitle(termTerm, for: .normal)
                                self.mcButton4.titleLabel?.minimumScaleFactor = 0.5
                                self.mcButton4.titleLabel?.numberOfLines = 3
                                self.mcButton4.titleLabel?.adjustsFontSizeToFitWidth = true
                                self.mcCorrectButton = 3
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
        })
        task.resume()
    }
    
    @IBAction func mcButton1Pressed(_ sender: UIButton) {
        mcButton1.isUserInteractionEnabled = false
        mcButton2.isUserInteractionEnabled = false
        mcButton3.isUserInteractionEnabled = false
        mcButton4.isUserInteractionEnabled = false
        
        gameTimer.invalidate()
        timerLabel.isHidden = true
        
        guard let conversation = activeConversation else { fatalError("Expected conversation.") }
        if (self.mcCorrectButton == 0) {
            if(self.originalSender == conversation.localParticipantIdentifier) {
                numberCorrect += 1
                rightWrongResult.text = "Correct 🤑"
                myScoreLabel.text = String(numberCorrect)
            } else {
                opponentNumberCorrect += 1
                rightWrongResult.text = "Correct 🤑"
                myScoreLabel.text = String(opponentNumberCorrect)
            }
            rightWrongResult.textColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            opponentLastCorrect = true
            mcButton1.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
        } else {
            if(self.originalSender == conversation.localParticipantIdentifier) {
                rightWrongResult.text = "Wrong 😤"
                myScoreLabel.text = String(numberCorrect)
            } else {
                rightWrongResult.text = "Wrong 😤"
                myScoreLabel.text = String(opponentNumberCorrect)
            }
            rightWrongResult.textColor = UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0)
            if (self.mcCorrectButton == 1) {
                mcButton2.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            } else if (self.mcCorrectButton == 2) {
                mcButton3.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            } else if (self.mcCorrectButton == 3) {
                mcButton4.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            }
            mcButton1.backgroundColor = UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0)
            opponentLastCorrect = false
        }
        opponentScoreLabel.isHidden = false
        rightWrongResult.isHidden = false
        myScoreLabel.isHidden = false
        sendButton.isHidden = false
    }
    
    @IBAction func mcButton2Pressed(_ sender: UIButton) {
        mcButton1.isUserInteractionEnabled = false
        mcButton2.isUserInteractionEnabled = false
        mcButton3.isUserInteractionEnabled = false
        mcButton4.isUserInteractionEnabled = false
        
        gameTimer.invalidate()
        timerLabel.isHidden = true
        
        guard let conversation = activeConversation else { fatalError("Expected conversation.") }
        if (self.mcCorrectButton == 1) {
            if(self.originalSender == conversation.localParticipantIdentifier) {
                numberCorrect += 1
                rightWrongResult.text = "Correct 🤑"
                myScoreLabel.text = String(numberCorrect)
            } else {
                opponentNumberCorrect += 1
                rightWrongResult.text = "Correct 🤑"
                myScoreLabel.text = String(opponentNumberCorrect)
            }
            rightWrongResult.textColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            opponentLastCorrect = true
            mcButton2.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
        } else {
            if(self.originalSender == conversation.localParticipantIdentifier) {
                rightWrongResult.text = "Wrong 😤"
                myScoreLabel.text = String(numberCorrect)
            } else {
                rightWrongResult.text = "Wrong 😤"
                myScoreLabel.text = String(opponentNumberCorrect)
            }
            rightWrongResult.textColor = UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0)
            if (self.mcCorrectButton == 0) {
                mcButton1.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            } else if (self.mcCorrectButton == 2) {
                mcButton3.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            } else if (self.mcCorrectButton == 3) {
                mcButton4.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            }
            opponentLastCorrect = false
            mcButton2.backgroundColor = UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0)
        }
        opponentScoreLabel.isHidden = false
        rightWrongResult.isHidden = false
        myScoreLabel.isHidden = false
        sendButton.isHidden = false
    }
    
    @IBAction func mcButton3Pressed(_ sender: UIButton) {
        mcButton1.isUserInteractionEnabled = false
        mcButton2.isUserInteractionEnabled = false
        mcButton3.isUserInteractionEnabled = false
        mcButton4.isUserInteractionEnabled = false
        
        gameTimer.invalidate()
        timerLabel.isHidden = true
        
        guard let conversation = activeConversation else { fatalError("Expected conversation.") }
        if (self.mcCorrectButton == 2) {
            if(self.originalSender == conversation.localParticipantIdentifier) {
                numberCorrect += 1
                rightWrongResult.text = "Correct 🤑"
                myScoreLabel.text = String(numberCorrect)
            } else {
                opponentNumberCorrect += 1
                rightWrongResult.text = "Correct 🤑"
                myScoreLabel.text = String(opponentNumberCorrect)
            }
            rightWrongResult.textColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            opponentLastCorrect = true
            mcButton3.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
        } else {
            if(self.originalSender == conversation.localParticipantIdentifier) {
                rightWrongResult.text = "Wrong 😤"
                myScoreLabel.text = String(numberCorrect)
            } else {
                rightWrongResult.text = "Wrong 😤"
                myScoreLabel.text = String(opponentNumberCorrect)
            }
            rightWrongResult.textColor = UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0)
            if (self.mcCorrectButton == 0) {
                mcButton1.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            } else if (self.mcCorrectButton == 1) {
                mcButton2.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            } else if (self.mcCorrectButton == 3) {
                mcButton4.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            }
            opponentLastCorrect = false
            mcButton3.backgroundColor = UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0)
        }
        opponentScoreLabel.isHidden = false
        rightWrongResult.isHidden = false
        myScoreLabel.isHidden = false
        sendButton.isHidden = false
    }
    
    @IBAction func mcButton4Pressed(_ sender: UIButton) {
        mcButton1.isUserInteractionEnabled = false
        mcButton2.isUserInteractionEnabled = false
        mcButton3.isUserInteractionEnabled = false
        mcButton4.isUserInteractionEnabled = false
        
        gameTimer.invalidate()
        timerLabel.isHidden = true
        
        guard let conversation = activeConversation else { fatalError("Expected conversation.") }
        if (self.mcCorrectButton == 3) {
            if(self.originalSender == conversation.localParticipantIdentifier) {
                numberCorrect += 1
                rightWrongResult.text = "Correct 🤑"
                myScoreLabel.text = String(numberCorrect)
            } else {
                opponentNumberCorrect += 1
                rightWrongResult.text = "Correct 🤑"
                myScoreLabel.text = String(opponentNumberCorrect)
            }
            rightWrongResult.textColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            opponentLastCorrect = true
            mcButton4.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
        } else {
            if(self.originalSender == conversation.localParticipantIdentifier) {
                rightWrongResult.text = "Wrong 😤"
                myScoreLabel.text = String(numberCorrect)
            } else {
                rightWrongResult.text = "Wrong 😤"
                myScoreLabel.text = String(opponentNumberCorrect)
            }
            rightWrongResult.textColor = UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0)
            if (self.mcCorrectButton == 0) {
                mcButton1.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            } else if (self.mcCorrectButton == 1) {
                mcButton2.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            } else if (self.mcCorrectButton == 2) {
                mcButton3.backgroundColor = UIColor(red: 26/255, green: 196/255, blue: 0/255, alpha: 1.0)
            }
            opponentLastCorrect = false
            mcButton4.backgroundColor = UIColor(red: 211/255, green: 0/255, blue: 0/255, alpha: 1.0)
        }
        opponentScoreLabel.isHidden = false
        rightWrongResult.isHidden = false
        myScoreLabel.isHidden = false
        sendButton.isHidden = false
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        if self.originalSender == conversation.localParticipantIdentifier && self.questionNumber - 1 != self.term_count { self.questionNumber += 1 }
        let quiz = Quiz(setTitle: self.setTitle, setAuthor: self.setAuthor, term_count: self.term_count, setID: self.setID, questionNumber: self.questionNumber, numberCorrect: self.numberCorrect, opponentNumberCorrect: self.opponentNumberCorrect, originalSender: self.originalSender!, timer: self.timer)
        composeMessage(quiz: quiz)
    }
    
    @IBAction func unlockTimedPressed(_ sender: UIButton) {
        IAPService.shared.purchase(product: .timed)
    }
    
    @objc func updateTimer() {
        seconds -= 1     // This will decrement(count down)the seconds.
        self.timerLabel.text = "\(self.seconds)" // This will update the label.
        if self.seconds <= 0 {
            self.timerLabel.text = "Time's Up!"
            self.idkButton.isUserInteractionEnabled = false
            self.termTextBox.isUserInteractionEnabled = false
            self.mcButton1.isUserInteractionEnabled = false
            self.mcButton2.isUserInteractionEnabled = false
            self.mcButton3.isUserInteractionEnabled = false
            self.mcButton4.isUserInteractionEnabled = false
            self.sendButton.isHidden = false
            self.opponentLastCorrect = false
        }
    }
    
}

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
    }
    
}
