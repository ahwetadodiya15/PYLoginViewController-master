# PYLoginViewController

You will be building the log-in screens for our application.

For ease of understanding, please download the following apps below. The design and UI/UX will be very similar.
- Refresh: https://itunes.apple.com/us/app/id582438442
- Humin: https://itunes.apple.com/us/app/humin-phone-and-contacts/id904402986?mt=8

**1) Welcome screen**

Standard welcome screen user sees when first downloading the app. The user has the option of logging in with Gmail or LinkedIn. Similar to the [Refresh](https://itunes.apple.com/us/app/id582438442) app welcome screen.

Consists of:
- Background image
- Label or image: ‘pyrus'
- Button: ‘LOG IN WITH GMAIL’
- Button: ‘LOG IN WITH LINKEDIN’

![alt text](https://github.com/loswojos/PYLoginViewController/blob/master/images/01_refresh_welcome.PNG)

**2) Authentication screen**

Once the user selects ‘GMAIL’ or ‘LINKEDIN’, they are taken to an authentication page. Both LinkedIn and Gmail have their own OAuth 2.0 protocols, which are displayed in the Web View. The navigation bar has a title: ‘Connect Google’ or ‘Connect LinkedIn’. There is also an option to cancel in the navigation bar. Upon successful authentication (i.e. user enters correct information: email/username and password), we extract information from the LinkedIn or Google account. **Please denote what information can be accessed for each API.** 

Similar to [Refresh](https://itunes.apple.com/us/app/id582438442) app authentication screen.

Consists of:
- Button: ‘X’ (cancel)
- Title: ‘Connect LinkedIn’ or ‘Connect Google’
- UIWebView

Useful classes:
- LinkedIn: IOSLinkedInAPI: https://github.com/jeyben/IOSLinkedInAPI
- Gmail: 

![alt text](https://github.com/loswojos/PYLoginViewController/blob/master/images/02_refresh_authenticate_linkedin.PNG)

**3) Grant access screen**

When an item is added (user clicks on ‘Add’ button), the appropriate action for each item is triggered and, upon success, the ‘Add’ button changes to a checkmark button. If an item has already been added, the ‘Add’ button should be a checkmark button. See [Refresh](https://itunes.apple.com/us/app/id582438442) app or [Humin](https://itunes.apple.com/us/app/id582438442) app for examples. 

Consists of:
- Background image
- Label: ‘Connect these plugins to power up Pyrus’
- Plugins:
 - Contacts (Required)
 - Notifications (Required)
 - Gmail
 - LinkedIn

The plugins represent the various integrations within the application. For example, the 'Contacts' plugin enables access to the iOS address book, the 'Notifications' plugin enables push notifications to the app, etc. Each plugin will consist of an icon, a label (e.g. 'Contacts'), and the appropriate button. If the plugin has NOT been enabled yet, display an 'Add' button. Otherwise, the button will be a checkmark icon.

**Note:** If 'Contacts' is added, but access is not granted internally, display the following alert.

Alert: Pyrus requires access to your contacts to manage connections. Please change your privacy settings. To activate Pyrus, go to: Settings > Privacy > Contacts.

If Gmail or LinkedIn is added, then take user to an authentication screen. Upon success, return to grant access screen and change button to checkmark.

![alt text](https://github.com/loswojos/PYLoginViewController/blob/master/images/03_humin_connect_accounts.PNG)

![alt text](https://github.com/loswojos/PYLoginViewController/blob/master/images/03_refresh_connect_accounts.PNG)

![alt text](https://github.com/loswojos/PYLoginViewController/blob/master/images/03_refresh_grant_access.PNG)

**4) Contact profile approve screen**

The navigation bar contains a title, ‘Profile’ and approve button that finalizes the login.  

Consists of:
- Profile picture
- TextField: First Name 
- TextField: Last Name
- TextField: Phone
- TextField: Email
- TextField: Website
- TextField: LinkedIn
- TextField: Twitter
