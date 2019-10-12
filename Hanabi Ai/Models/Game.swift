//
//  Game.swift
//  Hanabi Ai
//
//  Created by Geoff Hom on 9/17/19.
//  Copyright © 2019 Geoff Hom. All rights reserved.
//

import Foundation

/// A game of Hanabi, played by the computer against itself.
///
/// This is a class (vs. struct), because we need to control identity. E.g., if we simulate two identical games, they're still different.
class Game: ObservableObject {
    // TODO: deprecate?
    // Returns a string defining a random deck.
//    static var randomDeckDescription: String {
//        var deck = Deck()
//        deck.shuffle()
//        let description = deck.description
//        return description
//    }
    
    //TODO: May need to update which properties are Published. Think about it.
    
    /// The number of players.
    let numberOfPlayers: Int

    /// The method of arranging the deck; e.g., randomly, or with a specific order.
    let deckSetup: DeckSetup
    
    /// A human-readable description of the starting deck, used if `deckSetup` is `custom`.
    let customDeckDescription: String
    
    /// The deck before any cards are dealt.
    let startingDeck: Deck
    
    // TODO: This may not be needed, nor right. The next turn is made from the previous turn's deck, not this. So this probably isn't updated correctly. And if we copy the startingDeck to deal hands, then we don't need this property anymore.
    /// The current deck, which players draw from throughout the game.
    var deck: Deck
    
    /// The max number of clues you can have at any time.
    static let MaxClues = 8
    
    /// Each `Turn` in the game.
    @Published var turns: [Turn] = []
    
    /// A Bool that reflects whether this game is over.
    @Published var isOver = false
    
    /// TODO: Not sure what type this will be. It's everything needed to report the results. Like, the next turnStart, plus maybe more. probably want this @Published.
    let results = "testing"
    
    /// Creates a `Game` with the given number of players and deck setup.
    init(numberOfPlayers: Int, deckSetup: DeckSetup, customDeckDescription: String = "") {
        self.numberOfPlayers = numberOfPlayers
        self.deckSetup = deckSetup
        self.customDeckDescription = customDeckDescription
        
        /// The deck for the game.
        var deck: Deck
        
        switch self.deckSetup {
        case .random:
            deck = Deck()
            deck.shuffle()
        // TODO: add Custom deck setup. Read in custom deck description.
        case .custom:
            // Deck(custom: ???)
            deck = Deck()
        }
        self.deck = deck
        self.startingDeck = self.deck
        dealHands()
    }
    
    // MARK: Setup
    
    /// Deals starting hands.
    func dealHands() {
        /// An empty hand for each player.
        var hands = Array(repeating: Hand(), count: numberOfPlayers)
        
        /// The number of starting cards per player.
        ///
        /// 2–3 players: 5 each; 4–5 players: 4.
        let numberOfCardsPerPlayer = [2, 3].contains(numberOfPlayers) ? 5 : 4
        
        (1...numberOfCardsPerPlayer).forEach { _ in
            // Deal each player a card.
            // Using `indices` instead of looping over `hands`, because we need the reference.
            hands.indices.forEach {
                /// The top card of the deck.
                let topCard = deck.cards.removeFirst()
                
                hands[$0].cards += [topCard]
            }
        }
        
        /// The start of the first turn.
        let firstTurnStart = TurnStart(hands: hands, currentHandIndex: 0, deck: deck)
        
        /// The first turn.
        let firstTurn = Turn(number: 1, start: firstTurnStart)

        turns += [firstTurn]
    }
    
    // MARK: Play
        
    /// Plays turns until the game ends.
    func play() {
        while !isOver {
            /// The start of the next turn.
            let nextTurnStart = doAction()
            
            //TODO: this could be
            // while the game isn't over
            /// while !isOver(turnStart)
            /// while !isOver(gameState)
            // here, it's like game.state which is updated by game.doAction(), vs
            // game.state = game.doAction(). Tracking hidden mutations seems bad.
            
            /// Does an action and returns the resulting game state.
            ///game.doAction()
            ///
            /// Check
            ///game.checkIfOver()
            ///
            ///isOver = game.isOver()
            ///
            /// Does an action and returns the start of the next turn.
            // let nextTurnStart = game.doAction()
            
            // if
            
            
            /// Chooses and returns an action for the current turn.
            // ai.chosenAction()
            
            ///
            // doAction()

            
            /// The current turn, awaiting the player's action.
            var currentTurn = turns.last!
            
            currentTurn.action = action(for: currentTurn.start)
            
            /// The index for the current turn.
            let lastIndex = turns.count - 1
            
            turns[lastIndex] = currentTurn
            
            /// The start of the next turn.
            let nextTurnStart = currentTurn.start.did(currentTurn.action!)
            
            if isOver(at: nextTurnStart) {
                isOver = true
                // TODO: populate results. e.g., self.results = X
//                print("game is over!")
            } else {
                /// The next turn.
                let nextTurn = Turn(number: currentTurn.number + 1, start: nextTurnStart)
                
                turns += [nextTurn]
                // TODO: temp to avoid infinite loop
//                break
            }
        }
    }
    
    /// Returns an `Action` for the given `turnStart`.
    ///
    /// Under construction. The chosen action will depend on the game state and the AIs.
    func action(for turnStart: TurnStart) -> Action {
        // TODO: go beyond testing
        let action: Action
            //        let action = Action(type: .clue, number: 2)
            //        action = Action(type: .clue, number: 2)
        // temp; play first card in hand, for testing
        action = Action(type: .play, card: turnStart.hands[turnStart.currentHandIndex].cards.first!)
        return action
//            turn.action = Action(type: .clue, number: 2)
    //        turn.action = Action(type: .clue, suit: .white)
    //        turn.action = Action(type: .play, card: turn.hands[0].cards[2])
    //        turn.action = Action(type: .discard, card: turn.hands[0].cards[1])
        }
//    func playTurn(_ turn: inout Turn) {
//        turn.action = Action(type: .clue, number: 2)
////        turn.action = Action(type: .clue, suit: .white)
////        turn.action = Action(type: .play, card: turn.hands[0].cards[2])
////        turn.action = Action(type: .discard, card: turn.hands[0].cards[1])
//
//    }
    
    // move this to TurnStart? e.g., turn.start.turnStart(after: action) yeah
    /// Returns the `TurnStart` after the given `turn`.
    ///
    /// Assumes the `turn`'s action exists.
    func turnStart(after turn: Turn) -> TurnStart {
        /// The players' cards, which are unchanged from the end of the previous turn.
        let hands = turn.start.hands
                
        /// The `Array` index for the previous "current" player.
        let oldHandIndex = turn.start.currentHandIndex
        
        /// The `Array` index for the new current player (simple rotation).
        let currentHandIndex = (oldHandIndex == hands.count - 1) ? 0 : (oldHandIndex + 1)

        /// The remaining deck.
        let deck = turn.start.deck
        
        /// The number of clues for `TurnStart`.
        let clues: Int
        
        /// The number of strikes for `TurnStart`.
        let strikes: Int
        
        /// The score piles for `TurnStart`.
        let scorePiles: [ScorePile]
        
        /// The given `turn`'s action.
        let action = turn.action!
        
        switch action.type {
        case .play:
            /// The played card.
            let card = action.card!
            
            /// The matching score pile's index.
            // could be turn.start.scorePileIndex(for: card/suit?) or card.scorePileIndex
            // or returns Bool for valid/not like turnStart.allowsPlay(for: card), turnStart.canScore(card), turnStart.canPlay(card).
            let scorePileIndex = turn.start.scorePiles.firstIndex(where: {
                $0.suit == card.suit
            })!
            
            if turn.start.canScore(card) {
                turn.start.scorePilesF
            }
            
            // If the play is valid, then increase the score and check for bonus clue. Else, add a strike.
            if card.number == (turn.start.scorePiles[scorePileIndex].score + 1) {
                /// A mutable copy of the score piles.
                var newScorePiles = turn.start.scorePiles
                
                //TODO: testing; at least see how the code works if we do var newScorePile instead of (only?) var newScorePiles
                // or, try scorePile.score
                // or, turnStart.not update but like appending(), turnStart.updatingScore(with: card)
                // but will that work? we want it to return a copy of turnStart with the updated score
                turn.start.scorePiles[scorePileIndex].score = 3
                
                newScorePiles.removeLast()
                let testArray: [ScorePile] = turn.start.scorePiles.removeLast()
                let testArray2: [ScorePile] = turn.start.scorePiles.mutableCopy

                newScorePiles[scorePileIndex].score += 1
                
                /// If a score pile is finished, a clue is added.
                if card.number == 5 {
                    clues = min(Game.MaxClues, turn.start.clues + 1)
                } else {
                    clues = turn.start.clues
                }
                
                strikes = turn.start.strikes
                scorePiles = newScorePiles
            } else {
                // TODO: Put card in discard (really we just need to mark it as unavailable, same as any played card); when we add the ability to look at what could be in the deck, we'll worry about this. Current AI has x-ray.
                clues = turn.start.clues
                strikes = turn.start.strikes + 1
                scorePiles = turn.start.scorePiles
            }
            // draw card from deck and put in hand; ok, we draw a card from the deck, but it's immutable?
            // todo: this isn't as readable; add deck.removeTopCard?
            turn.start.deck.cards.removeFirst()
            
            /// A mutable copy of the deck.
            var newDeck = turn.start.deck
            
            /// The top card of the deck.
            let topCard = newDeck.removeTopCard()

            /// A mutable copy of the hands.
            var newHands = turn.start.hands
        case .discard:
            // TODO: implement .discard
            clues += 1
            // draw card from deck and put in hand
            /// The top card of the deck.
            // TODO: replace with like deck.topCard, named appropriately (deck.removeFirst()?)
            let topCard = deck.cards.removeFirst()
//            hands[index].cards.append(card) use += []
        case .clue:
            clues -= 1
        }
        return TurnStart(hands: hands, currentHandIndex: currentHandIndex, deck: deck, clues: clues, strikes: strikes, scorePiles: scorePiles)
    }
    
    // MARK: Game end
    
    /// Returns a `Bool` that reflects whether the game is over at the given `turnStart`.
    ///
    /// There are three ways for Hanabi to end: A 3rd strike, a perfect score of 25, or turns run out. The last case is when the last card has been drawn, and each player has had one more turn.
    func isOver(at turnStart: TurnStart) -> Bool {
        // TODO: So we need the score, the strikes, the deck
       
        if (turnStart.strikes == 3) {
            return true
            // TODO: this is temp for testing
        } else if (turnStart.clues == 5) {
            return true
            // TODO: perfect score. each score has to be 5.
//        } else if (scoresArePerfect(nextTurn.scores)) {
            // map?
//            turn.scores.forEach { score in
//                print("hi")
//            }
//            tempBool = true
//
//             // TODO: turns run out.
//        } else if (outOfTurns) {
//            ()
        } else {
            return false
        }
    }
    
//    func scoresArePerfect(scores: [Suit: Int]) -> Bool {
//
//    }
}
