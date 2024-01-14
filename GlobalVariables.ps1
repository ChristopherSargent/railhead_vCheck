# You can change the following defaults by altering the below settings:

# Set the following to true to enable the setup wizard for first time run
$SetupWizard = $true

# Start of Settings
# Report header
$reportHeader = "vCheck"
# Would you like the report displayed in the local browser once completed ?
$DisplaytoScreen = $true
# Display the report even if it is empty?
$DisplayReportEvenIfEmpty = $true
# Use the following item to define if an email report should be sent once completed
$SendEmail = $True
# Please Specify the SMTP server address (and optional port) [servername(:port)]
$SMTPSRV = "184.94.220.216"
# Would you like to use SSL to send email?
$EmailSSL = $false
# Please specify the email address who will send the vCheck report
$EmailFrom = "christopher.sargent@railhead.io"
# Please specify the email address(es) who will receive the vCheck report (separate multiple addresses with comma)
$EmailTo = "christopher.sargent@railhead.io"
# Please specify the email address(es) who will be CCd to receive the vCheck report (separate multiple addresses with comma)
$EmailCc = "christopher.sargent@railhead.io"
# Please specify an email subject
$EmailSubject = "$ Railhead vCheck Report"
# Send the report by e-mail even if it is empty?
$EmailReportEvenIfEmpty = $true
# If you would prefer the HTML file as an attachment then enable the following:
$SendAttachment = $True
# Set the style template to use.
$Style = "Clarity"
# Do you want to include plugin details in the report?
$reportOnPlugins = $true
# List Enabled plugins first in Plugin Report?
$ListEnabledPluginsFirst = $true
# Set the following setting to $true to see how long each Plugin takes to run as part of the report
$TimeToRun = $true
# Report on plugins that take longer than the following amount of seconds
$PluginSeconds = 30
# End of Settings

# End of Global Variables
