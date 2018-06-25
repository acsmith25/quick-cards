//
//  Questions.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

let allDecks = [ones, twos, threes, fours, fives, sixes, sevens, eights, nines, tens, elevens, twelves]

let ones = Deck(title: "Ones", cards: [ Card(question: "1 x 1", answer: "1"),
                     Card(question: "1 x 2", answer: "2"),
                     Card(question: "1 x 3", answer: "3"),
                     Card(question: "1 x 4", answer: "4"),
                     Card(question: "1 x 5", answer: "5"),
                     Card(question: "1 x 6", answer: "6"),
                     Card(question: "1 x 7", answer: "7"),
                     Card(question: "1 x 8", answer: "8"),
                     Card(question: "1 x 9", answer: "9"),
                     Card(question: "1 x 10", answer: "10"),
                     Card(question: "1 x 11", answer: "11"),
                     Card(question: "1 x 12", answer: "12") ])

let twos = Deck(title: "Twos", cards: [ Card(question: "2 x 1", answer: "2"),
                     Card(question: "2 x 2", answer: "4"),
                     Card(question: "2 x 3", answer: "6"),
                     Card(question: "2 x 4", answer: "8"),
                     Card(question: "2 x 5", answer: "10"),
                     Card(question: "2 x 6", answer: "12"),
                     Card(question: "2 x 7", answer: "14"),
                     Card(question: "2 x 8", answer: "16"),
                     Card(question: "2 x 9", answer: "18"),
                     Card(question: "2 x 10", answer: "20"),
                     Card(question: "2 x 11", answer: "22"),
                     Card(question: "2 x 12", answer: "24") ])

let threes = Deck(title: "Threes", cards: [ Card(question: "3 x 1", answer: "3"),
                       Card(question: "3 x 2", answer: "6"),
                       Card(question: "3 x 3", answer: "9"),
                       Card(question: "3 x 4", answer: "12"),
                       Card(question: "3 x 5", answer: "15"),
                       Card(question: "3 x 6", answer: "18"),
                       Card(question: "3 x 7", answer: "21"),
                       Card(question: "3 x 8", answer: "24"),
                       Card(question: "3 x 9", answer: "27"),
                       Card(question: "3 x 10", answer: "30"),
                       Card(question: "3 x 11", answer: "33"),
                       Card(question: "3 x 12", answer: "36") ])

let fours = Deck(title: "Fours", cards: [ Card(question: "4 x 1", answer: "4"),
                      Card(question: "4 x 2", answer: "8"),
                      Card(question: "4 x 3", answer: "12"),
                      Card(question: "4 x 4", answer: "16"),
                      Card(question: "4 x 5", answer: "20"),
                      Card(question: "4 x 6", answer: "24"),
                      Card(question: "4 x 7", answer: "28"),
                      Card(question: "4 x 8", answer: "32"),
                      Card(question: "4 x 9", answer: "36"),
                      Card(question: "4 x 10", answer: "40"),
                      Card(question: "4 x 11", answer: "44"),
                      Card(question: "4 x 12", answer: "48") ])

let fives = Deck(title: "Fives", cards: [ Card(question: "5 x 1", answer: "5"),
                      Card(question: "5 x 2", answer: "10"),
                      Card(question: "5 x 3", answer: "15"),
                      Card(question: "5 x 4", answer: "20"),
                      Card(question: "5 x 5", answer: "25"),
                      Card(question: "5 x 6", answer: "30"),
                      Card(question: "5 x 7", answer: "35"),
                      Card(question: "5 x 8", answer: "40"),
                      Card(question: "5 x 9", answer: "45"),
                      Card(question: "5 x 10", answer: "50"),
                      Card(question: "5 x 11", answer: "55"),
                      Card(question: "5 x 12", answer: "60") ])

let sixes = Deck(title: "Sixes", cards: [ Card(question: "6 x 1", answer: "6"),
                      Card(question: "6 x 2", answer: "12"),
                      Card(question: "6 x 3", answer: "18"),
                      Card(question: "6 x 4", answer: "24"),
                      Card(question: "6 x 5", answer: "30"),
                      Card(question: "6 x 6", answer: "36"),
                      Card(question: "6 x 7", answer: "42"),
                      Card(question: "6 x 8", answer: "48"),
                      Card(question: "6 x 9", answer: "54"),
                      Card(question: "6 x 10", answer: "60"),
                      Card(question: "6 x 11", answer: "66"),
                      Card(question: "6 x 12", answer: "72") ])

let sevens = Deck(title: "Sevens", cards: [ Card(question: "7 x 1", answer: "7"),
                       Card(question: "7 x 2", answer: "14"),
                       Card(question: "7 x 3", answer: "21"),
                       Card(question: "7 x 4", answer: "28"),
                       Card(question: "7 x 5", answer: "35"),
                       Card(question: "7 x 6", answer: "42"),
                       Card(question: "7 x 7", answer: "49"),
                       Card(question: "7 x 8", answer: "56"),
                       Card(question: "7 x 9", answer: "63"),
                       Card(question: "7 x 10", answer: "70"),
                       Card(question: "7 x 11", answer: "77"),
                       Card(question: "7 x 12", answer: "84") ])

let eights = Deck(title: "Eights", cards: [ Card(question: "8 x 1", answer: "8"),
                       Card(question: "8 x 2", answer: "16"),
                       Card(question: "8 x 3", answer: "24"),
                       Card(question: "8 x 4", answer: "32"),
                       Card(question: "8 x 5", answer: "40"),
                       Card(question: "8 x 6", answer: "48"),
                       Card(question: "8 x 7", answer: "56"),
                       Card(question: "8 x 8", answer: "64"),
                       Card(question: "8 x 9", answer: "72"),
                       Card(question: "8 x 10", answer: "80"),
                       Card(question: "8 x 11", answer: "88"),
                       Card(question: "8 x 12", answer: "96") ])

let nines = Deck(title: "Nines", cards: [ Card(question: "9 x 1", answer: "9"),
                      Card(question: "9 x 2", answer: "18"),
                      Card(question: "9 x 3", answer: "27"),
                      Card(question: "9 x 4", answer: "36"),
                      Card(question: "9 x 5", answer: "45"),
                      Card(question: "9 x 6", answer: "54"),
                      Card(question: "9 x 7", answer: "63"),
                      Card(question: "9 x 8", answer: "72"),
                      Card(question: "9 x 9", answer: "81"),
                      Card(question: "9 x 10", answer: "90"),
                      Card(question: "9 x 11", answer: "99"),
                      Card(question: "9 x 12", answer: "108") ])

let tens = Deck(title: "Tens", cards: [ Card(question: "10 x 1", answer: "10"),
                     Card(question: "10 x 2", answer: "20"),
                     Card(question: "10 x 3", answer: "30"),
                     Card(question: "10 x 4", answer: "40"),
                     Card(question: "10 x 5", answer: "50"),
                     Card(question: "10 x 6", answer: "60"),
                     Card(question: "10 x 7", answer: "70"),
                     Card(question: "10 x 8", answer: "80"),
                     Card(question: "10 x 9", answer: "90"),
                     Card(question: "10 x 10", answer: "100"),
                     Card(question: "10 x 11", answer: "110"),
                     Card(question: "10 x 12", answer: "120") ])

let elevens = Deck(title: "Elevens", cards: [ Card(question: "11 x 1", answer: "11"),
                        Card(question: "11 x 2", answer: "22"),
                        Card(question: "11 x 3", answer: "33"),
                        Card(question: "11 x 4", answer: "44"),
                        Card(question: "11 x 5", answer: "55"),
                        Card(question: "11 x 6", answer: "66"),
                        Card(question: "11 x 7", answer: "77"),
                        Card(question: "11 x 8", answer: "88"),
                        Card(question: "11 x 9", answer: "99"),
                        Card(question: "11 x 10", answer: "110"),
                        Card(question: "11 x 11", answer: "121"),
                        Card(question: "11 x 12", answer: "132") ])

let twelves = Deck(title: "Twelves", cards: [ Card(question: "12 x 1", answer: "12"),
                        Card(question: "12 x 2", answer: "24"),
                        Card(question: "12 x 3", answer: "36"),
                        Card(question: "12 x 4", answer: "48"),
                        Card(question: "12 x 5", answer: "60"),
                        Card(question: "12 x 6", answer: "72"),
                        Card(question: "12 x 7", answer: "84"),
                        Card(question: "12 x 8", answer: "96"),
                        Card(question: "12 x 9", answer: "108"),
                        Card(question: "12 x 10", answer: "120"),
                        Card(question: "12 x 11", answer: "132"),
                        Card(question: "12 x 12", answer: "144") ])
