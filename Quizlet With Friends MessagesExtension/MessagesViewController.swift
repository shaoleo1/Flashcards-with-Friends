//
//  MessagesViewController.swift
//  Quizlet With Friends MessagesExtension
//
//  Created by Leo Shao on 11/10/17.
//  Copyright © 2017 Leo Shao. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController, UISearchBarDelegate {
    
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
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var definitionTextBox: UITextField!
    
    // Declares an array of the study set IDs corresponding to the appropriate buttons.
    var buttonSetIDs = [Int?](repeating: nil, count: 10)
    var buttonSetTitles = [String?](repeating: nil, count: 10)
    var buttonSetAuthors = [String?](repeating: nil, count: 10)
    var buttonSetTermCounts = [Int?](repeating: nil, count: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBox.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        
        if let message = conversation.selectedMessage {
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
            
            let setID = getQueryStringParameter(url: (message.url?.absoluteString)!, param: "setID")
            // Creates a 'request' variable with the URL of the Quizlet API. Sets 'q' equal to the URL encoded search query. URL encoding simply replaces spaces in the search query with '%20' so it becomes a valid URL.
            var request = URLRequest(url: URL(string: "https://api.quizlet.com/2.0/sets/" + setID! + "?client_id=bFxdXkTKvW")!)
            // Sets the http method to GET which means GETting data FROM the API. There are two methods, GET and POST. POST means POSTing data TO the API. In this case, we're using GET.
            request.httpMethod = "GET"
            // Sets the file type that the data will be retrieved to be JSON, which is the standard format.
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Starts the HTTP session (connects to the API URL with the search query and GETs the data).
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                print(response!)
                do {
                    // Converts and saves the returned data into a variable called 'json' in appropriate JSON formatting.
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    // Creates a dictionary from the JSON file to look up the value for the key given.
                    if let dictionary = json as? [String: Any] {
                        // Creates an array of the returned terms.
                        if let nestedArray = dictionary["terms"] as? [Any] {
                            if let currentTerm = nestedArray[Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "questionNumber")!)! - 1] as? [String: Any] {
                                // Looks up the term and saves it into the variable 'term'.
                                if let term = currentTerm["term"] as? String {
                                    // Looks up the definition and saves it into the variable 'definition'.
                                    if let definition = currentTerm["definition"] as? String {
                                        // Prints 'term' - 'definition'.
                                        print("\(term) - \(definition)")
                                        DispatchQueue.main.async() {
                                            self.termLabel.text = term
                                            self.termLabel.isHidden = false
                                            self.definitionTextBox.isHidden = false
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
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
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
        
        let setID = getQueryStringParameter(url: (message.url?.absoluteString)!, param: "setID")
        // Creates a 'request' variable with the URL of the Quizlet API. Sets 'q' equal to the URL encoded search query. URL encoding simply replaces spaces in the search query with '%20' so it becomes a valid URL.
        var request = URLRequest(url: URL(string: "https://api.quizlet.com/2.0/sets/" + setID! + "?client_id=bFxdXkTKvW")!)
        // Sets the http method to GET which means GETting data FROM the API. There are two methods, GET and POST. POST means POSTing data TO the API. In this case, we're using GET.
        request.httpMethod = "GET"
        // Sets the file type that the data will be retrieved to be JSON, which is the standard format.
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Starts the HTTP session (connects to the API URL with the search query and GETs the data).
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                // Converts and saves the returned data into a variable called 'json' in appropriate JSON formatting.
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                // Creates a dictionary from the JSON file to look up the value for the key given.
                if let dictionary = json as? [String: Any] {
                    // Creates an array of the returned terms.
                    if let nestedArray = dictionary["terms"] as? [Any] {
                        if let currentTerm = nestedArray[Int(self.getQueryStringParameter(url: (message.url?.absoluteString)!, param: "questionNumber")!)! - 1] as? [String: Any] {
                            // Looks up the term and saves it into the variable 'term'.
                            if let term = currentTerm["term"] as? String {
                                // Looks up the definition and saves it into the variable 'definition'.
                                if let definition = currentTerm["definition"] as? String {
                                    // Prints 'term' - 'definition'.
                                    print("\(term) - \(definition)")
                                    DispatchQueue.main.async() {
                                        self.termLabel.text = term
                                        self.termLabel.isHidden = false
                                        self.definitionTextBox.isHidden = false
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
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    struct Quiz {
        let setTitle: String
        let setAuthor: String
        let term_count: Int
        let setID: Int
        var questionNumber: Int
        var numberCorrect: Int
        var opponentLastCorrect: Bool?
    }
    
    private func isSenderSameAsRecipient() -> Bool {
        guard let conversation = activeConversation else { return false }
        guard let message = conversation.selectedMessage else { return false }
        
        return message.senderParticipantIdentifier == conversation.localParticipantIdentifier
    }
    
    private func composeMessage(quiz: Quiz) {
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        let session = conversation.selectedMessage?.session ?? MSSession()
        let messageCaption = NSLocalizedString("Let's play a Quizlet game.", comment: "")
        
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "quizlet.png")
        layout.imageTitle = "\(quiz.setTitle) by \(quiz.setAuthor)"
        layout.caption = messageCaption
        layout.subcaption = "\(quiz.term_count) terms"
        
        var components = URLComponents()
        let queryItems = [URLQueryItem(name: "setID", value: String(quiz.setID)), URLQueryItem(name: "questionNumber", value: String(quiz.questionNumber)), URLQueryItem(name: "numberCorrect", value: String(quiz.numberCorrect))]
        components.queryItems = queryItems
        
        let message = MSMessage(session: session)
        message.layout = layout
        message.url = components.url!
        message.summaryText = "Quizlet With Friends"
        message.accessibilityLabel = messageCaption
        
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
    }

    @IBAction func setButtonPressed(_ sender: UIButton) {
        // Prints the ID of the button pressed. Each button has a tag from 1-10. It subtracts 1 because indexes go from 0-9.
        print(buttonSetIDs[sender.tag - 1]!)
        let quiz = Quiz(setTitle: buttonSetTitles[sender.tag - 1]!, setAuthor: buttonSetAuthors[sender.tag - 1]!, term_count: buttonSetTermCounts[sender.tag - 1]!, setID: buttonSetIDs[sender.tag - 1]!, questionNumber: 1, numberCorrect: 0, opponentLastCorrect: nil)
        composeMessage(quiz: quiz)
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
            print(response!)
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
                                            // Prints 'title' - 'author' - 'term_count'.
                                            print("\(title) - \(author) - \(term_count)")
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

}
