function onLoad()

    --the parameters for the solo, non-omnibus button on the arrow to start the game
    soloButton = {
        click_function = "soloButtonPressed",
        label = "Solo\nClassic",
        tooltip = "Solo, no Jack of Diamonds bonus.",
        scale = {3, 3, 3},
        font_size = 500,
        width = 2000,
        height = 1000,
        position = {8, 2, 5},
        rotation = {0, 180, 0},
        color = {0.25, 0.25, 0.25},
        font_color = {1, 1, 1}
    }

    --the parameters for the solo, omnibus button on arrow to start the game
    soloOmnibusButton = {
        click_function = "soloOmnibusButtonPressed",
        label = "Solo\nOmnibus",
        tooltip = "Solo, Jack of Diamonds is a bonus worth -10.",
        scale = {3, 3, 3},
        font_size = 500,
        width = 2000,
        height = 1000,
        position = {8, 2, -5},
        rotation = {0, 180, 0},
        color = {0.25, 0.25, 0.25},
        font_color = {1, 1, 1}
    }

    --the parameters for the team, non-omnibus button on the arrow to start the game
    teamButton = {
        click_function = "teamButtonPressed",
        label = "Team\nClassic",
        tooltip = "Team, no Jack of Diamonds bonus.",
        scale = {3, 3, 3},
        font_size = 500,
        width = 2000,
        height = 1000,
        position = {-8, 2, 5},
        rotation = {0, 180, 0},
        color = {0.25, 0.25, 0.25},
        font_color = {1, 1, 1}
    }

    --the parameters for the team, omnibus button on the arrow to start the game
    teamOmnibusButton = {
        click_function = "teamOmnibusButtonPressed",
        label = "Team\nOmnibus",
        tooltip = "Team, Jack of Diamonds is a bonus worth -10.",
        scale = {3, 3, 3},
        font_size = 500,
        width = 2000,
        height = 1000,
        position = {-8, 2, -5},
        rotation = {0, 180, 0},
        color = {0.25, 0.25, 0.25},
        font_color = {1, 1, 1}
    }

    lookButton = {
        click_function = "lookButtonPressed",
        label = "look\One",
        scale = {3, 3, 3},
        font_size = 500,
        width = 2000,
        height = 1000,
        position = {0.00, 1.1, -10.00},
        rotation = {0, 180, 0},
        color = {0.25, 0.25, 0.25},
        font_color = {1, 1, 1}
    }

    --create all buttons on the arrow
    self.createButton(soloButton)
    self.createButton(soloOmnibusButton)
    self.createButton(teamButton)
    self.createButton(teamOmnibusButton)

end
