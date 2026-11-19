# Kalamart's reMarkable templates

![](_img/banner.png)

This repository contains a few templates that I created for my personal use on the [reMarkable tablet](https://remarkable.com/). All of them are free to use and modify for non-commercial use.

These templates are made with the new ["rm methods"](https://spacepanda.se/articles/rm_methods.html) standard, which means they are generated "on the go" from a JSON description. That makes them much more flexible than PDF templates. They are compatible with the infinite scroll feature, and can be set page-by-page on any notebook, same as any other template. They also remain installed even after a software update.

> [!WARNING]
> **If you do not have an active Connect subscription:**
>
> By default, reMarkable's OS blocks access to the "methods" tab of the template selector if you don't have an active subscription. This will also block custom templates. If you happen to be in this situation, you can circumvent the block by installing [reManager](https://remanager.io/) on your PC or phone, connecting it to your tablet and using it to install the mod named "unlock-methods-content". All it does is remove this banner, and letting you use all your already installed "methods" templates.

> [!NOTE]
> **Known limitations:**
>
> - These custom templates aren't rendered when looking at the pages on the reMarkable cloud (web app, desktop app, smartphone app), since the template definition only exists locally on your device. You can however see them with screen share, as well as after a PDF or PNG export from the device.
> - I tried to make them compatible with different screen sizes, but I can only test on my reMarkable 2, so I cannot guarantee that the measurements will all be accurate on other models, especially if they have a different DPI.
> - The "rm methods" feature is only available for reMarkable software versions 3.17 and above.

## Available templates

**<details><summary>5mm grid</summary>**
A simple grid with 5mm spacing.

<img src="_img/5mm_grid.png" alt="5mm grid template preview" width="600"/>
</details>

**<details><summary>4mm grid</summary>**
A simple grid with 4mm spacing.

<img src="_img/4mm_grid.png" alt="4mm grid template preview" width="600"/>
</details>

**<details><summary>Checklist</summary>**
A compact checklist template with checkboxes and lines for writing. The lines are spaced by 8mm, and the checkboxes are 4mm in size.

<img src="_img/checklist.png" alt="Checklist template preview" width="600"/>
</details>

**<details><summary>Millimeter paper</summary>**
Standard graph paper with 1mm spacing, and darker lines every 5mm and 1cm. The lines are orange.

<img src="_img/millimeter_paper.png" alt="Millimeter paper template preview" width="600"/>
</details>

**<details><summary>Séyès</summary>**
This is a very popular French ruling system used for handwriting, with lines spaced by 8mm and additional horizontal lines every 2mm for letter height. The lines are dark blue and light blue, and there is a red vertical margin line on the left side of the page.

<img src="_img/seyes.png" alt="Séyès template preview" width="600"/>
</details>

**<details><summary>Webtoon</summary>**
This is a personal template I use for sketching my scrollable comics. It simply splits the page into 2 columns, which gives me a more manageable constant page width. There is also a very thin outline around the page, that is only visible when zooming out or scrolling. This template is only available in portrait orientation.

<img src="_img/webtoon.png" alt="Webtoon template preview" width="600"/>
</details>

**<details><summary>Tablet weaving</summary>**
Another highly specialized template, this one is for helping me draft tablet weaving designs. The left section is for showing card turns, and the right to preview the expected result. The amount of columns on the left side and the right side is the same, and the template scrolls infinitely. The grid on the right has the right proportions to imitate a tightly woven band.

This template also has a lansdscape version, which has more columns, but less visible rows, so it requires more scrolling if there are a lot of turns to write down.

<img src="_img/tablet_weaving.png" alt="Tablet weaving template preview" width="600"/>

Example of how I use it:

<img src="_img/tablet_weaving_example.png" alt="Tablet weaving template example" width="600"/>
</details>
  
## Automatic installation

This is the recommended way of installing these templates.

You will need access to a command line session on the tablet. If you don't want to deal with opening an SSH connection manually, you can use [reManager](https://remanager.io/) as a user-friendly graphical interface for connecting to your tablet.

> [!IMPORTANT]
> If you want to connect over wifi, you will first need to use a cable, so you can run the command that enables SSH over wlan. Newer models might also require you to switch to developer mode in order to use SSH on your tablet. See full instructions [here](https://remarkable.guide/guide/access/ssh.html).

Run the following command in the console:

```bash
bash -c "$(wget -qO- https://github.com/Kalamart1/reMarkable_templates/raw/master/install.sh)"
```

Then follow the installation wizard to install, update, or remove templates.

<img src="_img/installation_wizard.png" alt="Installation wizard" width="600"/>

Once you installed/removed all of the templates you want, press enter to exit the script, and restart your reMarkable device. You should now see the new templates in the "rM Methods" tab of the template picker.

<img src="_img/template_choice.png" alt="Template choice preview" width="600"/>

## Manual installation

In order to install those templates, you will need access to the tablet's linux filesystem, either via ssh or sftp. You can find instructions on how to do that [here](https://remarkable.guide/guide/access/ssh.html).

The template files should be copied to the `/home/root/.local/share/remarkable/xochitl` directory on the device (yes, thrown in the middle of the notebooks and other templates, without any dedicated subdirectory per template). The necessary files are the `.content`, `.metadata` and `.template` files.

> [!NOTE]
> **How to transfer files:**
>
> **<details><summary>Using `sftp` (works with most file explorers but not all)</summary>**
> `sftp` is a tool that uses the SSH protocol to transfer files. The advantage is that it allows you to navigate through the reMarkable's file system and copy files more easily, using the familiar graphical interface of your file explorer.
>
> Simply enter `sftp://root@IP_ADDRESS/home/root/.local/share/remarkable/xochitl` in your file explorer (replace `IP_ADDRESS` with the actual IP address of your reMarkable device), and you should be able to drag and drop the template files from your computer to the reMarkable.
> </details>
>
> **<details><summary>Using `scp` (via command line)</summary>**
> `scp` is a command-line tool to copy files from your computer to the reMarkable using the SSH protocol.
> 
> **Example:**
> ```bash
> cd checklist
> scp -r * root@IP_ADDRESS:/home/root/.local/share/remarkable/xochitl
> ```
> (Replace `IP_ADDRESS` with the actual IP address of your reMarkable device.)
> </details>

</br>

> [!TIP]
> Most templates have both a portrait and a landscape version. If you install them manually, I recommend installing both, since using a portrait template in landscape mode (or vice versa) can lead to the whole thing being stretched/squished.

Once you copied all of the templates you want, restart your reMarkable device. You should now see the new templates in the "rM Methods" tab of the template picker.

<img src="_img/template_choice.png" alt="Template choice preview" width="600"/>