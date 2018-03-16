# Memory Game
I wrote the app in Swift 3 and Xcode 8.2.1 with a deployment target of iOS 10.2.

## Updated for SceneKit
Since this is essentially a game played on a 2-dimensional board, I decided to take advantage of UIStackView's auto-layout capabilities and use the resulting cell positions to position the card nodes in SceneKit.

Once you get beyond the overhead of creating your 3D environment and assets, SceneKit gives you some things for free:
* Realistic shadows and reflections.
* Realistic movement and rotations.
* Accurate perspective.
* Realistic Physics (the cards tumble onto the floor at the end of the game).

## Additional Components for SceneKit

### Game2.scn
This contains the environment for the game. It includes a wood floor, a brick wall for the background, lighting and the camera position. To simplify the placement of cards, I used UIView points as the dimensional units in the scene. I then only needed to transform the card position from the UIStackView into the equivalent position in the scene.
### CardNode.swift
This is visual counterpart to CardView.swift. CardNode and CardView instances keep references to each other for managing game play.

## The Common Components
### LobbyViewController.swift
The UI was created in the storyboard and the only code is to pass the grid selection before segueing to the GamePlayViewController. The view supports rotation and adapts to any device format.
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
 * Even though not required, I added a few animations:
1. **Card Flip Animation**

    The **CardView** class contains *showFace()* and *showBack()* functions to flip the cards. They use the standard *UIView.transition()* class function to flip the cards between the card back and the face.
2. **Deal Cards Animation**

    I found that in order to animate the cards onto their correct resting place on the screen, I needed to let the UIStackViews lay out their subviews first. So I created the nested stackViews with the selected grid size with empty card buttons that had nil images.

    Dealing the cards is controlled by **GamePlayViewController.dealCards()** which iterates through the nested UIStackView and calls *'card.dealAfterDelay(_:withDuration)* for each card. *dealAfterDelay()* moves the invisible card offscreen, sets the back image then animates it into its proper location.
