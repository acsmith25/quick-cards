//
//  Questions.swift
//  MyApp
//
//  Created by Abby Smith on 6/20/18.
//  Copyright © 2018 Abby Smith. All rights reserved.
//

import Foundation

var allDecks: [Deck] = []
var userDecks: [Deck] = []
var decksInProgress: [Deck] = []
var defaultDecks = [ones, twos, threes, fours, fives, sixes, sevens, eights, nines, tens, elevens, twelves]

let ones = Deck(title: "Ones", cards: [Question("1 x 1"): Answer("1"),
                     Question("1 x 2"): Answer("2"),
                     Question("1 x 3"): Answer("3"),
                     Question("1 x 4"): Answer("4"),
                     Question("1 x 5"): Answer("5"),
                     Question("1 x 6"): Answer("6"),
                     Question("1 x 7"): Answer("7"),
                     Question("1 x 8"): Answer("8"),
                     Question("1 x 9"): Answer("9"),
                     Question("1 x 10"): Answer("10"),
                     Question("1 x 11"): Answer("11"),
                     Question("1 x 12"): Answer("12") ])

let twos = Deck(title: "Twos", cards: [ Question("2 x 1"): Answer("2"),
                     Question("2 x 2"): Answer("4"),
                     Question("2 x 3"): Answer("6"),
                     Question("2 x 4"): Answer("8"),
                     Question("2 x 5"): Answer("10"),
                     Question("2 x 6"): Answer("12"),
                     Question("2 x 7"): Answer("14"),
                     Question("2 x 8"): Answer("16"),
                     Question("2 x 9"): Answer("18"),
                     Question("2 x 10"): Answer("20"),
                     Question("2 x 11"): Answer("22"),
                     Question("2 x 12"): Answer("24") ])

let threes = Deck(title: "Threes", cards: [ Question("3 x 1"): Answer("3"),
                       Question("3 x 2"): Answer("6"),
                       Question("3 x 3"): Answer("9"),
                       Question("3 x 4"): Answer("12"),
                       Question("3 x 5"): Answer("15"),
                       Question("3 x 6"): Answer("18"),
                       Question("3 x 7"): Answer("21"),
                       Question("3 x 8"): Answer("24"),
                       Question("3 x 9"): Answer("27"),
                       Question("3 x 10"): Answer("30"),
                       Question("3 x 11"): Answer("33"),
                       Question("3 x 12"): Answer("36") ])

let fours = Deck(title: "Fours", cards: [ Question("4 x 1"): Answer("4"),
                      Question("4 x 2"): Answer("8"),
                      Question("4 x 3"): Answer("12"),
                      Question("4 x 4"): Answer("16"),
                      Question("4 x 5"): Answer("20"),
                      Question("4 x 6"): Answer("24"),
                      Question("4 x 7"): Answer("28"),
                      Question("4 x 8"): Answer("32"),
                      Question("4 x 9"): Answer("36"),
                      Question("4 x 10"): Answer("40"),
                      Question("4 x 11"): Answer("44"),
                      Question("4 x 12"): Answer("48") ])

let fives = Deck(title: "Fives", cards: [ Question("5 x 1"): Answer("5"),
                      Question("5 x 2"): Answer("10"),
                      Question("5 x 3"): Answer("15"),
                      Question("5 x 4"): Answer("20"),
                      Question("5 x 5"): Answer("25"),
                      Question("5 x 6"): Answer("30"),
                      Question("5 x 7"): Answer("35"),
                      Question("5 x 8"): Answer("40"),
                      Question("5 x 9"): Answer("45"),
                      Question("5 x 10"): Answer("50"),
                      Question("5 x 11"): Answer("55"),
                      Question("5 x 12"): Answer("60") ])

let sixes = Deck(title: "Sixes", cards: [ Question("6 x 1"): Answer("6"),
                      Question("6 x 2"): Answer("12"),
                      Question("6 x 3"): Answer("18"),
                      Question("6 x 4"): Answer("24"),
                      Question("6 x 5"): Answer("30"),
                      Question("6 x 6"): Answer("36"),
                      Question("6 x 7"): Answer("42"),
                      Question("6 x 8"): Answer("48"),
                      Question("6 x 9"): Answer("54"),
                      Question("6 x 10"): Answer("60"),
                      Question("6 x 11"): Answer("66"),
                      Question("6 x 12"): Answer("72") ])

let sevens = Deck(title: "Sevens", cards: [ Question("7 x 1"): Answer("7"),
                       Question("7 x 2"): Answer("14"),
                       Question("7 x 3"): Answer("21"),
                       Question("7 x 4"): Answer("28"),
                       Question("7 x 5"): Answer("35"),
                       Question("7 x 6"): Answer("42"),
                       Question("7 x 7"): Answer("49"),
                       Question("7 x 8"): Answer("56"),
                       Question("7 x 9"): Answer("63"),
                       Question("7 x 10"): Answer("70"),
                       Question("7 x 11"): Answer("77"),
                       Question("7 x 12"): Answer("84") ])

let eights = Deck(title: "Eights", cards: [ Question("8 x 1"): Answer("8"),
                       Question("8 x 2"): Answer("16"),
                       Question("8 x 3"): Answer("24"),
                       Question("8 x 4"): Answer("32"),
                       Question("8 x 5"): Answer("40"),
                       Question("8 x 6"): Answer("48"),
                       Question("8 x 7"): Answer("56"),
                       Question("8 x 8"): Answer("64"),
                       Question("8 x 9"): Answer("72"),
                       Question("8 x 10"): Answer("80"),
                       Question("8 x 11"): Answer("88"),
                       Question("8 x 12"): Answer("96") ])

let nines = Deck(title: "Nines", cards: [ Question("9 x 1"): Answer("9"),
                      Question("9 x 2"): Answer("18"),
                      Question("9 x 3"): Answer("27"),
                      Question("9 x 4"): Answer("36"),
                      Question("9 x 5"): Answer("45"),
                      Question("9 x 6"): Answer("54"),
                      Question("9 x 7"): Answer("63"),
                      Question("9 x 8"): Answer("72"),
                      Question("9 x 9"): Answer("81"),
                      Question("9 x 10"): Answer("90"),
                      Question("9 x 11"): Answer("99"),
                      Question("9 x 12"): Answer("108") ])

let tens = Deck(title: "Tens", cards: [ Question("10 x 1"): Answer("10"),
                     Question("10 x 2"): Answer("20"),
                     Question("10 x 3"): Answer("30"),
                     Question("10 x 4"): Answer("40"),
                     Question("10 x 5"): Answer("50"),
                     Question("10 x 6"): Answer("60"),
                     Question("10 x 7"): Answer("70"),
                     Question("10 x 8"): Answer("80"),
                     Question("10 x 9"): Answer("90"),
                     Question("10 x 10"): Answer("100"),
                     Question("10 x 11"): Answer("110"),
                     Question("10 x 12"): Answer("120") ])

let elevens = Deck(title: "Elevens", cards: [ Question("11 x 1"): Answer("11"),
                        Question("11 x 2"): Answer("22"),
                        Question("11 x 3"): Answer("33"),
                        Question("11 x 4"): Answer("44"),
                        Question("11 x 5"): Answer("55"),
                        Question("11 x 6"): Answer("66"),
                        Question("11 x 7"): Answer("77"),
                        Question("11 x 8"): Answer("88"),
                        Question("11 x 9"): Answer("99"),
                        Question("11 x 10"): Answer("110"),
                        Question("11 x 11"): Answer("121"),
                        Question("11 x 12"): Answer("132") ])

let twelves = Deck(title: "Twelves", cards: [ Question("12 x 1"): Answer("12"),
                        Question("12 x 2"): Answer("24"),
                        Question("12 x 3"): Answer("36"),
                        Question("12 x 4"): Answer("48"),
                        Question("12 x 5"): Answer("60"),
                        Question("12 x 6"): Answer("72"),
                        Question("12 x 7"): Answer("84"),
                        Question("12 x 8"): Answer("96"),
                        Question("12 x 9"): Answer("108"),
                        Question("12 x 10"): Answer("120"),
                        Question("12 x 11"): Answer("132"),
                        Question("12 x 12"): Answer("144") ])
