<h1>Zenstack</h1>
<hr/>
Zenstack aims to provide a customizable development environment for Openstack (OS) developers that can be deployed quickly and without much interaction. It is based on XenServer (dom0) but may support XCP in the future.

<h2>Friends and Family - Alternatives</h2>
<img src="http://roaet.com/images/Shiny-Stacked-Rocks.jpg" align="left"/>
Zenstack is currently in Pre-Alpha. Although it manages to perform all tasks successfully, it currently does not support customization and may not have your exact configuration. It is recommended that you ensure that the other available solutions are not better-fits for your particular situation. The below list is an incomplete list of alternatives:
<ul>
  <li><a href="http://devstack.org">devstack</a> - A very popular and even less interactive install of OS.</li>
</ul>
If you are aware of or are the author of a project much like Zenstack, please contact me and I will put a link to your project here.

If you have found that Zenstack is the answer for you, welcome!
<br/><br/>
<h2>Preparatory Steps</h2>
<ol>
  <li>If you have a license to apply to XenServer see the <a href="#applying-license-to-xenserver">section</a> below on applying it.</li>
  <li>If you are not on a stable (fast?) Internet connection this <b>will</b> fail. This is for you, wireless-users.</li>
</ol>

<h2>Usage (for current supported configuration)</h2>
<ol>
  <li>Create a new "Other Linux 2.6.x kernel 64-bit" VM in VMware [<b>recommended: 2 CPUs, 2048 GB RAM, 20GB HDD</b>].<br/><br/></li>
  <li>There is no real need for complicated passwords in this setup, but be conscious of the fact that passwords are currently viewable as plaintext.<br/><br/></li>
  <li>Install XenServer but ensure you do check '<b>enable thin provisioning</b>'. This will be referred to as your <b>dom0</b> henceforth.<br/><br/></li>
  <li>Note the IP address of your dom0 and ssh into the machine as <b>root</b><br/><br/></li>
  <li>Download the *.zip of this repository:
  <pre>wget --no-check-certificate https://github.com/roaet/zenstack/archive/master.zip</pre></li>
  <li>Extract the zip in <b>/root</b>.<br/><br/></li>
  <li><i>(Optional?)</i> If you have a license place it into the <b>same place</b> as xs_setup.sh.<br/><br/></li>
  <li>Change directory to where xs_setup.sh is.<br/><br/></li>
  <li>Run xs_setup.sh and follow the prompts (the default values are meant to be valid). If you make a mistake during this step it is safe to CTRL+C out of the program and try again. This process will create another VM inside of your dom0 where the OS services will run (regarded as <b>domU</b> henceforth).<br/><br/></li>
  <li>There are two opportunities for the setup to require more interaction after it begins.<br/><br/></li>
  <li>You may be required to get the XenServer kernel data from the DDK (rare as they are provided). Just follow the directions given.<br/><br/></li>
  <li>You will be prompted to mount the VMware Tools (Menu > Virtual Machine > Install VMware Tools). Note the prompt that mentions the kernel headers path. It would be wise to copy this path as you will need to enter it in during the VMware Tools installation.<br/><br/></li>
  <li>After this point the setup will not require further interaction.<br/><br/></li>
  <li>The XenServer setup will continue until it outputs: <b>all done :)</b>. This does not mean the domU you are creating to run the OS services has finished. Instructions will be displayed at the end of the dom0 install to monitor the installation progress of the domU. It is important you follow them exactly.<br/><br/></li>
  <li>If your internet connection is stable your VM will reboot (you will see /dev/rtc errors near the end if you are monitoring the domU, this is <i>okay</i>).<br/><br/></li>
  <li>You may run xs_setup.sh again and it will skip all steps that it can. Do this if you need to create a new VM (see: Creating new domU) or if the install failed. It is not tested if XenServer will handle multiple domUs running at the same time.
</ol>

<h2>Supported Configurations</h2>
<ul>
  <li>Debian Squeeze (domU) hosted by XenServer 6.0.0 (dom0) running in VMware fusion 4.1.3 on OS X 10.8.2 [2.3 Ghz i7, 8 GB]</li>
  <li>Debian Squeeze (domU) hosted by XenServer 6.0.0 (dom0) running in VMware fusion 5.0.2 on OS X 10.8.2 [2.3 Ghz i7, 8 GB]</li>
</ul>

<h2>Troubleshooting</h2>
<ul>
  <li>Be careful when entering values as there isn't currently a good way to 'undo'.</li>
  <li>It is unknown if the install will currently work without including license.txt</li>
  <li>If your domU fails during the install don't fret! Check out the <b>Creating new domU</b> section below.</li>
  <li>domU is failing immediately with disk write errors? You are probably out of storage space. See the <b>Freeing some space</b> section below.</li>
  <li>Although rare, it is possible that the domU will not boot properly, and when you get to the part of watching its installation it will just "Segmentation Fault" and disconnect you. It is recommened that you delete that domU and create a new one.
</ul>
<h2>Creating a new domU</h2>
Creating a new domU, in case your current one is corrupted, if it failed during the install, or if you just want a fresh start is very simple. Perform the following steps as root on your dom0:
<ol>
  <li>Find the domU's uuid and copy it by running the command: <pre>xe vm-list</pre></li>
  <li>Run the command: <pre>export uuid=&lt;PASTE UUID HERE&gt;</pre></li>
  <li>Shut down the current domU: <pre>xe vm-shutdown uuid=$uuid</pre></li>
  <li><i>(Do this to free up the space)</i>
  <pre>
  vdiuuid=`xe vbd-list vm-uuid=$uuid params=vdi-uuid --minimal`
  xe vdi-destroy uuid=$uuid params=$vdiuuid
  xe vm-destroy uuid=$uuid
  </pre></li>
  <li>Run xs_setup.sh as described above.<br/><br/></li>
</ol>

<h2>Bulk Clearing VDIs</h2>
If you haven't been removing domUs as per the above section, your storage repository will eventually fill up. When this happens all new domUs miraculously fail during install. Perform the following steps as root on your dom0 (<b>Note: you should destroy all domU's before doing this):
<ol>
  <li>Find the SR named "Local storage" and copy its UUID by running the command: <pre>xe sr-list</pre></li>
  <li>Run the command: <pre>export sruuid=&lt;PASTE SR-UUID HERE&gt;</pre></li>
  <li>Run the following command:
  <pre>
  xe vdi-list sr-uuid=$sruuid --minimal | awk 'BEGIN{FS=&quot;,&quot;}{for (i=1; i&lt;=NF; i++) system(&quot;xe vdi-destroy uuid=&quot;$i);}'
  </pre>
  </li>
</ol>

<h2>Applying License to XenServer</h2>
To apply the license to XenServer you must create a file called license.txt and place it in the same directory as the root setup script (xs_setup.sh). This license should look like this example, a PGP signed message:
<pre>
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

&lt;xe_license sku_type=&quot;SKU-TYPE&quot; version=&quot;5.0.0&quot; productcode=&quot;PRODUCT-CODE&quot; serialnumber=&quot;SERIAL-NUMBER&quot; sockets=&quot;32&quot; expiry=&quot;2082848400.000000&quot; human_readable_expiry=&quot;2036-01-01&quot; name=&quot;NAME&quot; address1=&quot;&quot; address2=&quot;&quot; city=&quot;&quot; state=&quot;&quot; postalcode=&quot;&quot; country=&quot;US&quot; company=&quot;COMPANY NAME&quot;/&gt;
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFKdfe3t8EvHqMeKcRAuMFAJ9kZC/VStlZBiMMtIYCt9lXQ5C2jQCfemEq
INYheaaSk2MqurkDk3gTgOg=
=/nrt
-----END PGP SIGNATURE-----
</pre>
The lack of newlines in the XML <b>is</b> very important.

<h2>Proposed Features</h2>
<ul>
  <li>Modular selection of OS services</li>
  <li>Boot up of additional services, such as Nicira's NVP</li>
  <li>Proper command line hiding of passwords</li>
  <li>Support for more versions of XenServer</li>
  <li>Support for XCP</li>
  <li>Support for different domU Operating Systems</li>
  <li>Less fragile file system searches</li>
  <li>Option to load OS services from different repositories</li>
  <li>Option to not load VMware tools</li>
  <li>Proper progress reports from domU to zenstack</li>
  <li>VDI cleanup tools</li>
</ul>
