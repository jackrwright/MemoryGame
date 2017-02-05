# Memory Game
I wrote the app in Swift 3 and Xcode 8.2.1 with a deployment target of iOS 10.2.
## The Components
### LobbyViewController.swift
The UI was created in the storyboard and the only code is to pass the grid selection before the segueing to the GamePlayViewController. The view supports rotation and adapts to any device format.
### GamePlayViewController.swift
This controller manages the game play. The only parts of its view that are created in the storyboard are the back button and an empty vertical UIStackView as a placeholder. The rest of it is generated in the controller. I chose to do it this way for flexibility. To add a new grid option only requires adding a button to the Lobby view controller in the storyboard, a segue with an appropriate identifier and tweaking a few constants in code.
#### CardView.swift
This is a subclass of UIButton and is created for each card on the fly. It provides initialization and functions to display the card faces and the card back as well as a shadow feature.
#### Card.swift
This provides a *CardType* enum that defines the possible card types and will generate a card deck given the number of cards desired.

## Code Flow
When the user chooses a grid option in the Lobby, the LobbyViewController passes the option, represented by the segue identifier to the GamePlayViewController.

 This ID is mapped to a tuple specifying the grid dimensions. An appropriately sized card deck is then generated and laid out on the view as nested UIStackViews. The orientation can be either portrait or landscape, but is locked into the orientation of the Lobby when the grid selection button was tapped.

 The grid layout is optimized for the orientation. For example, the 5 x 2 grid will have five cards along the widest screen dimension.

 The card tap logic is handled by the *cardWasTapped()* function.

 ## Observations/ Comments
 * The instructions said there would be 10 images for the card faces, but I could only find 8 unique images, so some faces are duplicated in the game.
 * Some of the images had no border, so I added a shadow effect to make the card shapes more distinct.
 * I could think of some animations that would be appropriate for the game (dealing the cards onto the board, card flipping, fancier segues, etc), but the instructions said they were "not included in the prototype", so in the interest of time I didn't add them. But, I certainly could if requested.