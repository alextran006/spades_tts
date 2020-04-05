function onload()

    deckPosition = {0.00, 4, 0.00}
    arrowStartPosition = {0.00, 5, 0.00}
    centerZone = getObjectFromGUID("f6815d")
    tableZone = getObjectFromGUID("a98311")
    arrow = getObjectFromGUID("556d30")

    suits = {"club", "diamond", "spade", "heart"}
    --keep these parralel with suits
    suitSymbols = {"♧", "♢", "♠", "♥"}
    suitColors = {
        "000000",    --black
        "FF0000",    --red
        "000000",    --black
        "FF0000",    --red

    }
    values = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
    --numbers indicate how many players clockwise the player is passing, 0 means no passing
    passDirections = {0, 0, 0, 0}
    --game can be played solo (4 players individually)
    --or in teams of 2 (pairs across from each other)
    gameModes = {"solo", "team"}

    game = {
        started = false,
        mode = gameModes[1],
        --omnibus means the Jack of Diamonds is worth -10 points
        omnibus = false
    }


    round = {
        started = false,
        --this should increment after each round is complete
        passDirection = passDirections[1],
        --true if the 2 of clubs must be played
        open = false,
        --to keep track if players can lead hearts yet
        heartsBroken = false,
        --once this counter hits 0, the round is over
        tricksRemaining = 13
    }


    trick = {
        started = false,
        --will be one of the four suits a player chooses to play first
        --if nil, player can lead any card (except hearts if they are not broken)
        lead = nil,
        --once 4 cards are played, the trick is finished
        cardsRemaining = 4
    }

    white = {
        name = "White",    --players color name
        nickname = "South",    --players position at the table (reads like a compass)
        handZone = getObjectFromGUID("1125d3"),    --the players scripting zone in their hand
        playZone = getObjectFromGUID("6a1b52"),    --the scripting zone where players place cards
        trickZone = getObjectFromGUID("2f040b"),    --the scripting zone where tricks are placed
        text = getObjectFromGUID("9e6c81"),     --the text where player's name and score are displayed
        turn = false,       --whether it is that player's turn or not
        score = 0,          --the cumulative score for the player
        roundScore = 0,     --the points the player has accumulated for the round
        farthestRightCard = {6, 4.23, -14.00},  --used for sorting player's hands
        arrowPosition = {0.00, 0.96, -3.00},   --where the arrow is positioned when it is that player's turn
        arrowRotation = {0.00, 90.00, 0.00},   --the arrow's rotation when it is that player's turn
        --the position of that player's cards when they win a trick
        trickLocation = {
            position = {6.00, 1.1, -8.00}
        },
        cardRotation = {0.00, 180.00, 0.00},   --the rotation of the player's cards when played or in hand
        --the placement of cards when played from the hand by either AI or the 2 of clubs
        cardPlacement = {
            position = {0.00, 1.1, -8.00}
        }
    }

    orange = {
        name = "Orange",
        nickname = "West",
        handZone = getObjectFromGUID("1163c5"),
        playZone = getObjectFromGUID("c9a39a"),
        trickZone = getObjectFromGUID("426672"),
        text = getObjectFromGUID("d7225e"),
        turn = false,
        score = 0,
        roundScore = 0,
        farthestRightCard = {-14.00, 4.23, -6},
        arrowPosition = {-3.00, 0.96, 0.00},
        arrowRotation = {0.00, 180.00, 0.00},
        trickLocation = {
            position = {-8.00, 1.1, -6.00}
        },
        cardRotation = {0.00, 270.00, 0.00},
        cardPlacement = {
            position = {-8.00, 1.1, 0.00}
        }
    }

    green = {
        name = "Green",
        nickname = "North",
        handZone = getObjectFromGUID("538694"),
        playZone = getObjectFromGUID("ded190"),
        trickZone = getObjectFromGUID("b3813b"),
        text = getObjectFromGUID("d427af"),
        turn = false,
        score = 0,
        roundScore = 0,
        farthestRightCard = {-6, 4.23, 14.00},
        arrowPosition = {0.00, 0.96, 3.00},
        arrowRotation = {0.00, 270.00, 0.00},
        trickLocation = {
            position = {-6.00, 1.1, 8.00}
        },
        cardRotation = {-8.00, 0.00, 0.00},
        cardPlacement = {
            position = {0.00, 1.1, 8.00}
        }
    }

    purple = {
        name = "Purple",
        nickname = "East",
        handZone = getObjectFromGUID("18924d"),
        playZone = getObjectFromGUID("0ac1fd"),
        trickZone = getObjectFromGUID("3ce3c5"),
        text = getObjectFromGUID("9093c0"),
        turn = true,
        score = 0,
        roundScore = 0,
        farthestRightCard = {14.00, 4.23, 6},
        arrowPosition = {3.00, 0.96, 0.00},
        arrowRotation = {0.00, 0.00, 0.00},
        trickLocation = {
            position = {8.00, 1.1, 6.00}
        },
        cardRotation = {0.00, 90.00, 0.00},
        cardPlacement = {
            position = {8.00, 1.1, 0.00}
        }
    }

    players = {white, orange, green, purple}

end

function soloButtonPressed()

    game.mode = gameModes[1]
    game.omnibus = false
    startGame()

end

function soloOmnibusButtonPressed()

    game.mode = gameModes[1]
    game.omnibus = true
    startGame()

end

function teamButtonPressed()

    game.mode = gameModes[2]
    game.omnibus = false
    startGame()

end

function teamOmnibusButtonPressed()

    game.mode = gameModes[2]
    game.omnibus = true
    startGame()

end

function startGame()

    announceMode()
    arrow.clearButtons()
    startLuaCoroutine(Global, "startNextRound")

end

--announces to all players what mode(s) have been selected
function announceMode()

    local gameTypeMessage = ""      --solo or team game starting?
    local scoreTypeMessage = ""     --complimentary to the above, just who will share a score if applicable
    local omnibusMessage = ""       --is jack of diamonds worth anything?

    if game.mode == gameModes[1] then
        gameTypeMessage = "Solo game starting."
        scoreTypeMessage = "Each player has an individual score."
    elseif game.mode == gameModes[2] then
        gameTypeMessage = "Team game starting."
        scoreTypeMessage = "North + South will share a score. East + West will share a score."
    end

    if game.omnibus == false then
        omnibusMessage = "Jack of Diamonds is worth 0 points."
    elseif game.omnibus == true then
        omnibusMessage = "Jack of Diamonds is a bonus card worth -10 points."
    end

    broadcastToAll(gameTypeMessage, {0.627, 0.125, 0.941})
    broadcastToAll(scoreTypeMessage, {0.5, 0.5, 0.5})
    broadcastToAll("----------------------------", {0.5, 0.5, 0.5})
    broadcastToAll(omnibusMessage, {0.856, 0.1, 0.094})

end

function startNextRound()

    game.started = true

    for k,v in pairs(tableZone.getObjects()) do
        if v.tag == "Card" or v.tag == "Deck" then
            v.setRotation({180,0,0})
            v.setPositionSmooth(deckPosition)
            v.setLock(false)
            for i=1, 5 do coroutine.yield() end
        end
    end

    for i=1, 150 do coroutine.yield()
    end

    for k,v in pairs(centerZone.getObjects()) do
        if v.tag == "Deck" then
            v.shuffle(10)
            for i=1, 75 do coroutine.yield()
            end
        end
    end

    startLuaCoroutine(Global, "dealCards")

return 1
end

--returns the player whose turn it is
function getPlayerTurn()

    for p,player in pairs(players) do
        if player.turn == true then
            return player
        end
    end

end

--gets the number of cards held in a suit. string argument
function getNumOfSuitHeld(suit)

    local player = getPlayerTurn()  --to prevent accidental reading of other players' hands
    local numOfCards = 0

    for v,value in pairs(player.memory.south[suit .. "s"]) do
        print("v: " .. v)
        print("value: " .. value)
    end

end

function dealCards()

    --find the deck of cards
    for o,object in pairs(centerZone.getObjects()) do
        if object.tag == "Deck" then
            --if the deck has more than 4 cards, cards will be dealt individually
            if object.getQuantity() > 4 then
                for p,player in pairs(players) do
                    object.dealToColor(1, player.name)
                    --a small pause to prevent game freezing for non-host players and it just looks better
                    for i=1, 3 do coroutine.yield()
                    end
                end
                --recursion until the deck reaches 4 cards
                startLuaCoroutine(Global, "dealCards")
                return 1
            end
            --once the deck hits 4 cards, all players receive 1 card and the recursion ends
            if object.getQuantity() == 4 then
                for p,player in pairs(players) do
                    object.dealToColor(1, player.name)
                end
            end
        end
    end

    --a brief pause to make sure all cards are in hand before sorting
    for i=1, 50 do coroutine.yield()
    end

    --if there is no passing, the next round begins automatically
    if round.passDirection == 0 then
        broadcastToAll("There is no passing in this round", {0.5, 0.5, 0.5})
        startLuaCoroutine(Global, "startRound")
    end

    if round.passDirection >= 1 then
        --sorts the cards in every player's hand
        startLuaCoroutine(Global, "sortHand")
        broadcastToAll("Stack 3 cards together in front of you face down from your hand.", {1, 1, 1})
        if round.passDirection == 1 then
            broadcastToAll("These will be passed to your LEFT.", {0.5, 0.5, 0.5})
        elseif round.passDirection == 2 then
            broadcastToAll("These will be passed ACROSS from you.", {0.5, 0.5, 0.5})
        elseif round.passDirection == 3 then
            broadcastToAll("These will be passed to your RIGHT.", {0.5, 0.5, 0.5})
        end
    end

return 1
end

--for moving to the winner of a trick or the player holding the 2 of clubs
function setArrowOnPlayer(player)

    arrow.setPositionSmooth(player.arrowPosition)
    arrow.setRotation(player.arrowRotation)

end

--for when a trick is in progress
function moveTurnClockwise()

    local nextPlayerIndex = 0
    local nextPlayer = nil

    --find whose turn it is
    for p,player in pairs(players) do
        if player.turn == true then
            player.turn = false
            nextPlayerIndex = p + 1
            break
        end
        --locks all cards once turn is finished
        for o,object in pairs(player.handZone.getObjects()) do
            if object.tag == "Card" then
                object.interactable = false
                object.ignore_fog_of_war = false
            end
        end
    end

    if nextPlayerIndex > 4 then
        nextPlayerIndex = nextPlayerIndex - 4
    end

    --set the turn to the next player and remove 1 from the number of cards remaining in the trick
    nextPlayer = players[nextPlayerIndex]
    trick.cardsRemaining = trick.cardsRemaining - 1

    --if there are more cards to go, move the arrow and set it to the next clockwise player's turn
    if trick.cardsRemaining > 0 then
        setArrowOnPlayer(nextPlayer)
        nextPlayer.turn = true
        lockIllegalCards()
    --otherwise the cards and turn will be given to the winner of the trick
    elseif trick.cardsRemaining == 0 then
        lockAllCards()
        startLuaCoroutine(Global, "findTrickWinner")
    end

end

--locks all cards in every player's hand
function lockAllCards()

    for p,player in pairs(players) do
        for o,object in pairs(player.handZone.getObjects()) do
            if object.tag == "Card" then
                object.interactable = false
                object.ignore_fog_of_war = false
            end
        end
    end

end

function lockIllegalCards()

    local hasLeadSuit = false
    local playerToLock = nil
    local suit = nil
    local value = nil

    --find whose turn it is in order to lock their cards
    for p,player in pairs(players) do
        if player.turn == true then
            playerToLock = player
            break
        end
    end

    lockAllCards()

    --preliminary checking if player has lead suit
    for o,object in pairs(playerToLock.handZone.getObjects()) do
        if object.tag == "Card" and object.getDescription() == trick.lead then
            hasLeadSuit = true
        end
    end

    --unlock all legal cards for the player whose turn it is
    for o,object in pairs(playerToLock.handZone.getObjects()) do
        if object.tag == "Card" then
            suit = object.getDescription()
            value = object.getName()
            --if the player has no lead suit and is not leading
            if hasLeadSuit == false and trick.lead ~= nil then
                --All cards are legal
                object.interactable = true
            --if the player has the lead suit
			elseif suit == trick.lead then
                object.interactable = true
            --if the player is leading
            elseif trick.lead == nil then
                --if the card is not a spade or is a spade and spades are broken
                if suit ~= "spade" or (suit == "spade" and round.heartsBroken == true) or hasAllSpades(playerToLock) == true then
                    object.interactable = true
                end
            end
        end
    end

end


--function to check if the player has only spades
function hasAllSpades(playerToLock)
	for o,object in pairs(playerToLock.handZone.getObjects()) do
        if object.tag == "Card" and object.getDescription() ~= "spades" then
            return 0
        end
    end
    round.heartsBroken == true
    return 1
end

--finds the winner of a trick by finding the highest card of the lead suit
function findTrickWinner()

    local winningPlayer = nil
    --a brief pause to let players see all cards played
    for i=1, 100 do coroutine.yield() end

    --loops through all cards in front of players
    for v,value in pairs(values) do
        for p,player in pairs(players) do
            for o,object in pairs(player.playZone.getObjects()) do
                --loops through the card ranks from 2-Ace. only the cards of the lead suit are counted
                if object.tag == "Card" and object.getDescription() == trick.lead and object.getName() == values[v] then
                    winningPlayer = players[p]
				end
            end
        end
    end
	for v,value in pairs(values) do
        for p,player in pairs(players) do
            for o,object in pairs(player.playZone.getObjects()) do
                --loops through the card ranks from 2-Ace. only the cards of the spades are counted
                if object.tag == "Card" and object.getDescription() == "spade" and object.getName() == values[v] then
                    winningPlayer = players[p]
                end
            end
        end
    end

    takeTrick(winningPlayer)

return 1
end

--gathers cards and gives points to the particular player
function takeTrick(winner)

    showPreviousTrick()

    --set the rotation of won cards to be face down
    local winnerCardRotation = {
        180,
        winner.cardRotation[2],
        winner.cardRotation[3]
    }

    --after the first trick is finished, points can be played
    round.open = false
    --the current trick is reset so any suit can be played
    trick.cardsRemaining = 4
    trick.lead = nil
    round.tricksRemaining = round.tricksRemaining - 1
    setArrowOnPlayer(winner)
    winner.turn = true

    --gathers all cards and gives them to the player that won them
    for p,player in pairs(players) do
        for o,object in pairs(player.playZone.getObjects()) do
            if object.tag == "Card" then
                object.setRotation(winnerCardRotation)
                object.setLock(false)
                object.clone(winner.trickLocation)
                object.destruct()
                --if the trick contains a spade, hearts are broken
                if object.getDescription() == "spade" then
                    winner.roundScore = winner.roundScore + 1
                    round.heartsBroken = true
                end
                if object.getDescription() == "spade" and object.getName() == "Q" then
                    winner.roundScore = winner.roundScore + 13
                end
                if object.getDescription() == "diamond" and object.getName() == "J" and game.omnibus == true then
                    winner.score = winner.score - 10
                    --if a teammate wins the jack, the other partner's score must update to match
                    if game.mode == gameModes[2] then
                        if winner == players[1] or winner == players[3] then
                            players[1].score = winner.score
                            players[3].score = winner.score
                        elseif winner == players[2] or winner == players[4] then
                            players[2].score = winner.score
                            players[4].score = winner.score
                        end
                    end
                end
            end
        end
    end

    checkForOnlyHearts(winner)

    if round.tricksRemaining == 0 then
        startLuaCoroutine(Global, "finishRound")
        arrow.setPositionSmooth(arrowStartPosition)
    else
        lockIllegalCards()
    end

    updateScoreText()

end

--shows the previous 4 cards played in the notes
function showPreviousTrick()

    local preText = "[b]Previous Trick:\n\n"
    local postText = "[/b]"
    local space = "        "
    local valuesPlayed = {}
    local suitsPlayed = {}

    for p,player in pairs(players) do
        for o,object in pairs(player.playZone.getObjects()) do
            if object.tag == "Card" then
                table.insert(valuesPlayed, p, object.getName())
                table.insert(suitsPlayed, p, object.getDescription())
            end
        end
    end

    for sp,suitPlayed in pairs(suitsPlayed) do
        for s,suit in pairs(suits) do
            if suitPlayed == suit then
                suitsPlayed[sp] = "[" .. suitColors[s] .. "]" .. suitSymbols[s] .. "[-]"
                break
            end
        end
    end

    --since notes are set top to bottom left to right, North (3rd player) is first, then West (2nd player) and so on
    setNotes(
        preText ..
        "North" .. space .. "\n" ..
        valuesPlayed[3] .. suitsPlayed[3] .. space .. "\n\n" ..
        valuesPlayed[2] .. suitsPlayed[2] .. space .. "  " .. valuesPlayed[4] .. suitsPlayed[4] .. "\n\n" ..
        valuesPlayed[1] .. suitsPlayed[1] .. space ..
        "\nSouth" .. space .. "\n" ..
        postText
    )

end

--updates the score text for each player
function updateScoreText()

    for p,player in pairs(players) do
        player.text.setValue(player.nickname .. "\n" .. player.score .. " (" .. player.roundScore .. ")")
    end

end

--if hearts are not broken but a player holds only hearts, they make break hearts by leading them
function checkForOnlyHearts(player)

    --check the player's hand if it contains only hearts. if so, hearts are broken to allow that player to lead
    for o,object in pairs(player.handZone.getObjects()) do
        local suit = object.getDescription()
        if suit == "club" or suit == "diamond" or suit == "spade" then
            return
        end
    end

    --round.heartsBroken = true

end

--resets all necessary variables and updates cumulative scores for players
function finishRound()

    round.started = false
    round.heartsBroken = false
    round.open = true
    round.tricksRemaining = 13
    setNextPassDirection()
    updateScores()
    resetTurns()

    for i=1, 100 do coroutine.yield() end

    for p,player in pairs(players) do
        if player.score >= 100 then
            finishGame()
            return 1
        end
    end

    startLuaCoroutine(Global, "startNextRound")

return 1
end

--adds each players'/team's round score to their total score or shoot the moon if possible
function updateScores()

    local north = players[3]
    local east = players[4]
    local south = players[1]
    local west = players[2]

    if game.mode == gameModes[1] then
        for p,player in pairs(players) do
            --if a player collected all 26 points, they have shot the moon
            if player.roundScore == 26 then
                shootMoon(player)
                break
            else
                --otherwise, the points collected are added to each players' score
                player.score = player.score + player.roundScore
            end
        end
    end

    --team variation
    if game.mode == gameModes[2] then
        --set both partners' scores to the sum of each other
        south.roundScore = south.roundScore + north.roundScore
        north.roundScore = south.roundScore
        east.roundScore = east.roundScore + west.roundScore
        west.roundScore = east.roundScore
        --if either team takes all 26 points, that team receives 0 points and the other team receives 26
        if south.roundScore == 26 then
            broadcastToAll("North and South shot the moon! East and West + 26", {1, 1, 1})
            north.roundScore = 0
            south.roundScore = 0
            east.roundScore = 26
            west.roundScore = 26
        elseif west.roundScore == 26 then
            broadcastToAll("East and West shot the moon! North and South + 26", {1, 1, 1})
            north.roundScore = 26
            south.roundScore = 26
            east.roundScore = 0
            west.roundScore = 0
        end

        for p,player in pairs(players) do
            player.score = player.score + player.roundScore
        end
    end

end

--reset the turns and round scores back to 0
function resetTurns()

    for p,player in pairs(players) do
        player.roundScore = 0
        player.turn = false
    end

end

function setNextPassDirection()

    local nextDirection = 1

    for d,direction in pairs(passDirections) do
        if round.passDirection == passDirections[d] then
            nextDirection = nextDirection + d
            break
        end
    end

    if nextDirection > 4 then
        nextDirection = nextDirection - 4
    end

    round.passDirection = passDirections[nextDirection]

end

function shootMoon(shooter)

    --since high can be up to 99 and low can be anything below 100,
    --variables must start on opposite ends
    local highScore = 0
    local lowScore = 100

    broadcastToAll(shooter.nickname .. " (" .. shooter.name .. ")" .. " shot the moon!", {1, 1, 1})

    for p,player in pairs(players) do
        --don't count the shooter's score as the lowest score if they are in last
        if player.score > highScore and player ~= shooter then
            highScore = player.score
        end
        if player.score < lowScore then
            lowScore = player.score
        end
    end

    --if the discrepancy between shooter and low man is less than 26 points
    --or the high score is below 74, add 26 to all
    if shooter.score - lowScore <= 26 or highScore < 74 then
        for p,player in pairs(players) do
            if player ~= shooter then
                player.score = player.score + 26
            end
        end
        broadcastToAll("All others +26", {1, 1, 1})
        --otherwise the shooter is more than 26 points behind and adding
        --26 points would result in a loss. instead, subtract 26
    else
        shooter.score = shooter.score - 26
        broadcastToAll(shooter.nickname .. " -26", {1, 1, 1})
    end

end

function sortHand()

    --orders cards in players hands by suit (order is in 'suits' table)
    --also orders cards by value (order is in 'values' table)
    for s,suit in pairs(suits) do
        for v,value in pairs(values) do
            for p,player in pairs(players) do
                for o,object in pairs(player.handZone.getObjects()) do
                    if object.tag == "Card" and object.getName() == values[v] and object.getDescription() == suits[s] then
                        object.setPosition(player.farthestRightCard)
                        object.ignore_fog_of_war = false
                        object.interactable = false
                        object.interactable = true
                        --a small pause to make sure that cards aren't moved in the same frame
                        for i=1, 1 do coroutine.yield() end
                        break
                    end
                end
            end
        end
    end

return 1
end

--for the AI to use when it is finished
--also used for automatically playing the 2 of clubs
function playCard(color, suit, value)

    for k,v in pairs(color.handZone.getObjects()) do
        if v.getDescription() == suit and v.getName() == value then
            v.clone(color.cardPlacement)
            v.destruct()
            break
        end
    end

end

--whenever players or AI plays a card
function onObjectEnterScriptingZone(zone, enter_object)

    --if a round is not started, nothing should happen
    if round.started == false then
        return
    end

    --checks if the entered zone is the play zone of the player whose turn it is
    for p,player in pairs(players) do
        if player.turn == true and zone == player.playZone and enter_object.tag == "Card" then
            enter_object.setLock(true)
            if enter_object.held_by_color ~= nil then
                enter_object.clone(player.cardPlacement)
                enter_object.destruct()
            end
            if trick.lead == nil then
                trick.lead = enter_object.getDescription()
            end
            moveTurnClockwise()
        end
        --this will place cards that were cloned into the zone into the right position
        if player.playZone == zone and enter_object.held_by_color == nil then
            enter_object.setPositionSmooth(player.cardPlacement.position)
        end
    end

    --to prevent multiple cards from being in a play zone during a round (cheat prevention)
    for p,player in pairs(players) do
        if zone == player.playZone then
            for o,object in pairs(player.playZone.getObjects()) do
                if object.tag == "Card" then
                    enter_object.setPositionSmooth({0,2,0})
                    return
                end
            end
        end
    end


end

--used for the pass before each hand. whenever a card is put into a deck and makes 3,
--if all players have also done so, they are passed to the appropriate player
function onObjectEnterContainer(container, enter_object)

    checkForPassedCards()
    lockWonCards()

end

function lockWonCards()

    if game.started == false or round.started == false then
        return
    end

    for p,player in pairs(players) do
        for o,object in pairs(player.trickZone.getObjects()) do
            if object.tag == "Deck" then
                object.interactable = false
            end
        end
    end

end

--checks if all players have chosen their 3 cards to pass yet
function checkForPassedCards()

    if game.started == false or round.passDirection == 0 or round.tricksRemaining < 13 then
        return
    end

    local passesComplete = 0

    for p,player in pairs(players) do
        for o,object in pairs(player.playZone.getObjects()) do
            if object.tag == "Deck" and object.getQuantity() == 3 then
                passesComplete = passesComplete + 1
            end
        end
    end

    if passesComplete == 4 then
        passCards()
    end

end

function passCards()

    --for finding which player receives whose cards
    local playerIndex = 1

    --passes cards from in front of players to the appropriate player
    for p,player in pairs(players) do
        playerIndex = (4 - round.passDirection + p) % 4
        if playerIndex == 0 then
            playerIndex = 4
        end
        for o,object in pairs(players[playerIndex].playZone.getObjects()) do
            if object.tag == "Deck" and object.getQuantity() == 3 then
                object.deal(3, player.name)
            end
        end
    end

    startLuaCoroutine(Global, "startRound")

end

--starts the round once passing is complete
function startRound()

    for i=1, 125 do coroutine.yield() end

    round.started = true
    round.open = true
    startLuaCoroutine(Global, "sortHand")
    for i=1, 100 do coroutine.yield() end

    --points the arrow to the player that holds the 2 of clubs
    --also plays the 2 of clubs automatically and sets the lead suit to clubs
    --[[
    for p,player in pairs(players) do
        for o,object in pairs(player.handZone.getObjects()) do
            if object.getName() == "2" and object.getDescription() == "club" then
                setArrowOnPlayer(player)
                playCard(player, "club", "2")
                trick.lead = "club"
                player.turn = true
                break
            end
        end
    end
    --]]
    lockIllegalCards()
return 1
end

function finishGame()

    local lowScore = 125    --it is possible to win with all players above 100

    --first iteration to find lowest score
    for p,player in pairs(players) do
        if player.score < lowScore then
            lowScore = player.score
        end
    end

    --second iteration to announce winner(s)
    for p,player in pairs(players) do
        if player.score == lowScore then
            broadcastToAll(player.nickname .. " (" .. player.name .. ")" .. " wins with a score of " .. player.score .. "!", {1, 1, 1})
        end
    end

end
