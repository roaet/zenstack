<h1>zenstack</h1>
<hr/>
Zenstack aims to provide a customizable development environment for Openstack (OS) developers that can be deployed quickly and without much interaction. It is based on XenServer (dom0) but may support XCP in the future.

<h2>Preparatory Steps</h2>
<ol>
  <li>If you have a license to apply to XenServer see the section below on applying it.</li>
</ol>

<h2>Usage</h2>
<ol>
  <li>Use it!</li>
  <li>There is no real need for complicated passwords in this setup, but be conscious of the fact that passwords are currently viewable as plaintext.</li>
  <li>More soon.</li>
</ol>

<h2>Supported Configurations</h2>
<ul>
  <li>Debian Squeeze (domU) hosted by XenServer 6.0.0 (dom0) running in VMware fusion 4.1.3 on OS X 10.8.2 [2.3 Ghz i7, 8 GB]</li>
</ul>

<h2>Troubleshooting</h2>
<ul>
  <li>Be careful when entering values as there isn't currently a good way to 'undo'.</li>
  <li>It is unknown if the install will currently work without including license.txt</li>
</ul>
<h2>Proposed Features</h2>
<ul>
  <li>Modular selection of OS services</li>
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

<h2>Applying License to XenServer</h2>
To apply the license to XenServer you must create a file called license.txt and place it in the same directory as the root setup script (xs_setup.sh). This license should look like this example, a PGP signed message:
<pre>
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

&lt;xe_license sku_type=&quot;XE Express&quot; version=&quot;5.0.0&quot; productcode=&quot;PRODUCT-CODE&quot; serialnumber=&quot;SERIAL-NUMBER&quot; sockets=&quot;32&quot; expiry=&quot;2082848400.000000&quot; human_readable_expiry=&quot;2036-01-01&quot; name=&quot;NAME&quot; address1=&quot;&quot; address2=&quot;&quot; city=&quot;&quot; state=&quot;&quot; postalcode=&quot;&quot; country=&quot;US&quot; company=&quot;COMPANY NAME&quot;/&gt;
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFKdfe3t8EvHqMeKcRAuMFAJ9kZC/VStlZBiMMtIYCt9lXQ5C2jQCfemEq
INYheaaSk2MqurkDk3gTgOg=
=/nrt
-----END PGP SIGNATURE-----
</pre>
The lack of newlines in the XML <b>is</b> very important.
