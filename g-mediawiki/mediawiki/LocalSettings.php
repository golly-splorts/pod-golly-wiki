<?php
$wgSitename = "Golly.Life Wiki";
$wgMetaNamespace = "Golly";

# from http://www.mediawiki.org/wiki/Manual:Short_URL#Recommended_how-to_guide_.28setup_used_on_Wikipedia.29
$wgScriptPath = "/w";      # Path to the actual files. This should already be there
$wgArticlePath = "/wiki/$1";  # Virtual path. This directory MUST be different from the one used in $wgScriptPath
$wgUsePathInfo = true;        # Enable use of pretty URLs

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

# The protocol and server name to use in fully-qualified URLs
# $wgServer = 'https://bespin.charles';
# $wgCanonicalServer = 'https://bespin.charles';
$wgServer = 'https://wiki.golly.life';
$wgCanonicalServer = 'https://wiki.golly.life';

## The URL path to static resources (images, scripts, etc.)
$wgStylePath = "$wgScriptPath/skins";
$wgResourceBasePath = $wgScriptPath;

# The URL path to the logo.  Make sure you change this from the default,
# or else you'll overwrite your logo when you upgrade!
#$wgLogo = "$wgResourceBasePath/skins/Bootstrap2/defcon.png"; # resources/assets/wiki.png";
$wgLogo = "$wgResourceBasePath/assets/gollylogo.png";

# UPO means: this is also a user preference option

$wgEnableEmail = false;
$wgEnableUserEmail = false; # UPO

$wgEmergencyContact = "apache@🌻.invalid";
$wgPasswordSender = "apache@🌻.invalid";
$wgEnotifUserTalk = false; # UPO
$wgEnotifWatchlist = false; # UPO
$wgEmailAuthentication = false;

# Database settings
$wgDBtype = "mysql";
$wgDBserver = getenv('MYSQL_HOST');
$wgDBname = getenv('MYSQL_DATABASE');
$wgDBuser = getenv('MYSQL_USER');
$wgDBpassword = getenv('MYSQL_PASSWORD');

# MySQL specific settings
$wgDBprefix = "";
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";
$wgDBmysql5 = true;

# Shared memory settings
$wgMainCacheType = CACHE_ACCEL;
$wgMemCachedServers = [];

# To enable image uploads, make sure the 'images' directory
# is writable, then set this to true:
$wgEnableUploads = true;
$wgMaxUploadSize = 1024*1024*100; # 100 MB
# also set in php.ini

$wgUseImageMagick = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";

# InstantCommons allows wiki to use images from https://commons.wikimedia.org
$wgUseInstantCommons = false;

# Allow specific file extensions
$wgStrictFileExtensions = false;
$wgFileExtensions[] = 'pdf';
$wgFileExtensions[] = 'svg';
$wgFileExtensions[] = 'mm';
$wgFileExtensions[] = 'png';
$wgFileExtensions[] = 'jpg';
$wgFileExtensions[] = 'JPG';
$wgFileExtensions[] = 'jpeg';
$wgFileExtensions[] = 'py';

# Allow any file extensions, but print a warning if not in $wgFileExtensions[]
$wgCheckFileExtensions = false;

# do not send pingback to https://www.mediawiki.org
$wgPingback = false;

# If you use ImageMagick (or any other shell command) on a
# Linux server, this will need to be set to the name of an
# available UTF-8 locale
$wgShellLocale = "C.UTF-8";
#$wgShellLocale = "en_US.utf8"; # from original pod-charlesreid1

# Site language code, should be one of the list in ./languages/data/Names.php
$wgLanguageCode = "en";

$wgSecretKey = getenv('MEDIAWIKI_SECRETKEY');

# Changing this will log out all existing sessions.
$wgAuthenticationTokenVersion = "1";

# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
$wgUpgradeKey = "984c1d9858dabc27";

# No license info
$wgRightsPage = "";
$wgRightsUrl = "";
$wgRightsText = "";
$wgRightsIcon = "";

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = "/usr/bin/diff3";

###############################################
################# set skin ####################

#wfLoadSkin('Vector');
#$wgDefaultSkin = "vector";
wfLoadSkin('Medik');
$wgDefaultSkin = "Medik";
//$wgMedikColor = '#181a21';
$wgMedikColor = '#211a18';
$wgAllowSiteCSSOnRestrictedPages = true;
$wgMedikShowLogo = 'sidebar';

# Change to true for debugging
$wgShowExceptionDetails=false;

# When you make changes to this configuration file, this will make
# sure that cached pages are cleared.
session_save_path("tmp");
$wgCacheEpoch = max( $wgCacheEpoch, gmdate( 'YmdHis', @filemtime( __FILE__ ) ) );

############################################################
############# Ch4zm-Modified Settings ####################

# Allow external images (to do this, simply insert the image's URL)
# http://url.for/some/image.png
# But these cannot be resized.
$wgAllowExternalImages = true;

# Use ImageMagick
$wgUseImageMagic=true;

# $wgAllowDisplayTitle - Allow the magic word { { DISPLAYTITLE: } } to override the title of a page.
$wgAllowdisplayTitle=true;

# Log IP addresses in the recentchanges table.
$wgPutIPinRC=false;

# Getting some weird "Error creating thumbnail: Invalid thumbnail parameters" messages w/ thumbnail
# http://www.gossamer-threads.com/lists/wiki/mediawiki/169439
$wgMaxImageArea=64000000;
$wgMaxShellMemory=0;

$wgFavicon="$wgScriptPath/favicon.ico";

######################
# Edit permissions

# only admin can edit
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['user']['edit'] = false;
$wgGroupPermissions['sysop']['edit'] = true;

# only admin can register new accounts
$wgGroupPermissions['*']['createaccount'] = false;
$wgGroupPermissions['user']['createaccount'] = false;
$wgGroupPermissions['sysop']['createaccount'] = true;

# only admin can upload
$wgGroupPermissions['*']['upload'] = false;
$wgGroupPermissions['user']['upload'] = false;
$wgGroupPermissions['sysop']['upload'] = true;

$wgGroupPermissions['*']['reupload'] = false;
$wgGroupPermissions['user']['reupload'] = false;
$wgGroupPermissions['sysop']['reupload'] = true;

###############################
# wikieditor extension
wfLoadExtension( 'WikiEditor' );

##############################
# Parser functions
# http://www.mediawiki.org/wiki/Extension:ParserFunctions
# http://en.wikipedia.org/wiki/Template_talk:Navbox

wfLoadExtension( 'ParserFunctions' );

#############################
# Everything below is for Medik
# and blaseball wiki templates.

# Scribunto (lua?)
wfLoadExtension( 'Scribunto' );

# Variables and Loops
wfLoadExtension( 'Loops' );
wfLoadExtension( 'Variables' );

#############################################
# Fix cookies crap

session_save_path("/tmp");

##############################################
# Secure login

$wgSecureLogin = true;

###################################
# Raw html

$wgRawHtml = true;

# but also keep things locked down
$wgUseRCPatrol=true;
$wgNewUserLog=true;

##################################
# Paths

$wgUploadPath = "$wgScriptPath/images";
$wgUploadDirectory = "$IP/images";
$wgTmpDirectory = "$wgUploadDirectory/tmp";
#$wgUploadBaseUrl = false; # not sure about why this one too...
$wgVerifyMimeType = false;
$wgDebugLogFile = "/var/log/apache2/wiki.log";

################################
# Speed things up

# Use file caching
$wgUseFileCache = true;
$wgFileCacheDirectory = "$IP/cache";
$wgShowIPinHeader = false;

# Cache sidebar
$wgEnableSidebarCache = true;

# Disable page counters
$wgDisableCounters = true;
$wgHitcounterUpdateFreq = 500;

# Enable miser mode
$wgMiserMode = true;

# Run outstanding jobs every 10 page loads
$wgJobRunRate = 10;
