// var location = 'westeurope'

@description('The location all resources will be deployed to')
param location string = 'westeurope'

var tags = {}
var imagePublisher = 'gbordier'
var prefix = 'devbox'
var aibIdentityName ='MI-DEV-TEST'

// Scripts
var commonScript = split(loadTextContent('installScripts/common.ps1'), ['\r','\n'])
var developerScript = split(loadTextContent('installScripts/developers.ps1'), ['\r','\n'])

module developerImage 'modules/main.bicep' = {
  name: 'developer-custom-image'
  params: {
    prefix: prefix
    imageName: 'Win10Developers'
    aibIdentityName: aibIdentityName
    location: location
    imagePublisher: imagePublisher
    tags: tags
    customize: [
      {
        type: 'PowerShell'
        name: 'Common Setup'
        inline: commonScript
        valid_exit_codes: ['0','3010']
      }
      {
        type: 'PowerShell'
        name: 'Developer Tooling'
        inline: developerScript
        valid_exit_codes: ['0','3010']
      }
  {
    type: 'WindowsRestart'
    restartCommand: 'shutdown /r /f /t 0'
    restartCheckCommand: 'echo Azure-Image-Builder-Restarted-the-VM  > c:\\buildArtifacts\\azureImageBuilderRestart.txt'
    restartTimeout: '5m'
  }
    ]
  }
}

