# Object Placement Tool

This tool was originally created to streamline the process of placing a large amount of guideposts along all of the roads in GTA 5.

The alternative method was using codewalker - A great application, but wasn't design for this sort of task. In order to place all the guideposts it would be very tedious, time consuming and repetitive.

Our team didn't have much time - and I personally wasn't keen on us all getting carpal tunnel or RSI 😅

So I put some time into this tool to save us all the time and pain. I put some extra effort into UX:
- **A contextual cursor** - Changes based on mode and validity of the action being attempted.
- **Custom Camera System** - It utilizes a custom camera system I made, modified for specific needs of the tool. (3 Camera modes included)
- **Controls UI** - Shows controls and updates based on the current mode you are in.
- **Refining controls** - Testing control schemes and working out what works best and felt natural.
- **Minimizing Text Commands** - Text commands are slow, finding alternate methods to speed things up.


Thankfully, it was all worth the effort!

## Features of the tool

- **Quick object placement**
- **Automatic Heading Calculation** (Useful for the guideposts as the rotate with the road)
- **Live preview** - Immediately see the prop in the game itself, no restart required.
- **Export to YMAP** (Only configured for our guideposts, but easily changeable)

## Tool in use

### Create a new object line:

We will use bollards as an example

https://github.com/user-attachments/assets/3cd7b18c-24ac-4861-a16c-6ea25275e63a

### Add points

Growing the length of the object line

https://github.com/user-attachments/assets/59d7137c-b322-4a92-bfae-bf749f3990e4

### Remove points

https://github.com/user-attachments/assets/1fde533a-0144-441d-9666-ebc84df86b8b

### Move points

https://github.com/user-attachments/assets/9a7a301f-4a98-41c2-a25c-2d98ecf5c3ec

### Add points between other points

Adding density to the object line

https://github.com/user-attachments/assets/745acf5e-31c0-4668-9d96-89ce61314370

### Rotate point

In our example, this bollard was rotated 45 degrees, because of the automatic heading calculations and way the neighbours are positioned.

We don't like that, so we are going to override its heading - to make it more square like the others

https://github.com/user-attachments/assets/b7d5dce3-bf96-490a-8110-15860bf8bf89

### Remove object line

Easy clean up when your done!

https://github.com/user-attachments/assets/8413ce29-ce07-44c6-99ae-50c912535e25

