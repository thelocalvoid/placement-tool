# Object Placement Tool

This tool was originally created to streamline the process of placing a large amount of [guideposts](https://www.delnorth.com.au/products/guideposts/) along all of the roads in GTA 5.

The alternative method was using [codewalker](https://github.com/dexyfex/CodeWalker) - A great application, but wasn't design for this sort of task. In order to place all the guideposts it would be very tedious, time consuming and repetitive.

Our team didn't have much time - and I personally wasn't keen on us all getting carpal tunnel or RSI 😅

### We needed a faster solution

So I put some time into this tool to save us alot of time and pain. I also put some extra effort into UX:
- **A contextual cursor** - Changes based on mode and validity of the action being attempted.
- **Custom Camera System** - It utilizes a custom camera system I made, modified for specific needs of the tool. (2 Camera modes included: 3D mode, 2D Map view)
- **Controls UI** - Shows controls and updates based on the current mode you are in.
- **Refining controls** - Testing control schemes and working out what works best and felt natural.
- **Minimizing Text Commands** - Text commands are slow, finding alternate methods to speed things up.


Thankfully, it was all worth the effort!

We we're able to complete long stretches of roads in under 10 minutes (Guide posts on both sides, every 10-30 meters).

## Features of the tool

- **Quick object placement**
- **Prop-terrain alignment** - An option to snap the rotation of the prop to the ground beneath it.
- **Random Rotation** - Some random, seed based rotation options to add variety to each object instance.
- **Automatic Heading Calculation** (Useful for the guideposts, as they face adjacent to the road)
- **Live preview** - Immediately see the prop in the game itself, no restart required.
- **Export to YMAP** (Only configured for our guideposts, but easily changeable)

  The export automatically sorts the objects into multiple files - for performance (streaming in/out of YMAP files). Based on the grid the object is placed in.

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

Easy to adjust positions with two clicks.

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

## Additional options

### Automatic Heading Calculation

Street signs are a great example.
Notice they rotate based on the position of their neighbours

https://github.com/user-attachments/assets/49ffa034-3e55-4bc9-b384-3d02b9147266

https://github.com/user-attachments/assets/995824c7-937e-40f2-870a-3c59caeb2aa0

### Random Rotation

Okay, maybe street signs aren't a great example for this, but could be great for more organic objects

https://github.com/user-attachments/assets/86594440-09e5-407b-ac93-b38f72fedf2d

### Reverse Rotation

Great for if you accidently build the line in the wrong direction 😅

https://github.com/user-attachments/assets/04651b86-07e2-4c30-bd3f-cdad2cc34de8

### Random Wobble

Each object has a wobble direction based on it's seed.

You can change the intensity of the wobble:

https://github.com/user-attachments/assets/ac3ea6d2-f297-4cab-ae4b-75376df83749




