# controlm_toolset

## aapi_upgrade.ps1
  - Purpose: Downloads and installs the AAPI release identified in the parameters
  - Parameters: Version (default=9) Release (default=20) Fixpack (no default)
  - Use: ./aapi_upgrade.ps1 -fixpack 225
  
## sndSMSviaATT.sh
  - Purpose: as a control-M Shout, sends an SMS message via a REST request
  - Parameters: standard shout parameters $2 is used as message and contains the phone and text message separated by "=="
  - Use: as part of a Control-M shout to program

## SendAlarmToScript
  - Purpose: use Alarm to script configuration to send alerts to an ITSM system
  - Check the [README](sendAlarmToScript\README.md) file for the project
  - Use: as part of a Control-M shout to program