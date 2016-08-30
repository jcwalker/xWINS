{AppVeyor build status badge for master branch}

# xWINS

This is a module for managing Windows Internet Name Service (WINS).  This module requires the server has the WINS Windows Feature to be installed.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## How to Contribute
If you would like to contribute to this repository, please read the DSC Resource Kit [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

## Resources

* **xWinsReplicationPartner** A resource to add, remove, and manage WINS replication partners

### xWinsReplicationPartner

A resource to add, remove, and manage WINS replication partners.) 

* **Partner**: IP address of the WINS replication partner.
* **Type**: Indicates the type of partner to add: 0-Pull, 1-Push, 2-Both (default).
* **Ensure**: Specifies to either add or remote the partner. 

## Versions

### Unreleased

### 1.0.0.0

* Initial release with the following resources:
    * xWinsReplicationPartner

