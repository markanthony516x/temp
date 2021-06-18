#  ===============================================================================================
# | Test-MvaTcpPort                                                                               |
#  ===============================================================================================
# |                                                                                               |
# | Checks whether a connection can be made to a remote machine on a specific TCP port.           |
# |                                                                                               |
# | Copyright (c) Mark Anthony. All rights reserved.                                              |
# | Licensed under the GPLv3 License.                                                             |
# |                                                                                               |
#  ===============================================================================================

<#

.SYNOPSIS
Attempts to establish a TCP connection to a remote machine on a specified port, returning a simple true or false.

.DESCRIPTION
Attempts to establish a TCP connection to a remote machine on a specified port, returning a simple true or false.

.PARAMETER computerName
Specify the remote computer to attempt to connect to.

.PARAMETER port
Specify the remote TCP port to attempt to connect to.

.PARAMETER timeout
Specify a connection timeout in millieseconds.

.INPUTS
String

.OUTPUTS
Boolean

.NOTES
Version:        1.0.0
Author:         Mark Anthony
Creation Date:  20/12/2018

.EXAMPLE
C:\PS>Test-MvaTcpPort -computerName Web1 -port 443 -timeout 1000
True

This example tests port 443 on a remote computer.

#>
Function Test-MvaTcpPort
{

    [CmdletBinding()]
    [OutputType('System.Boolean')]

    Param (

        [Parameter( Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True )]
        [ValidateNotNullOrEmpty()]
        [Alias( 'cn' )]
        [String]$computerName,
    
        [Int]$port = 80,
        [Int]$timeout = 3000

    )

    PROCESS {

        Try
        {
            # create a tcpClient object
            $tcpClient = New-Object Net.Sockets.TcpClient

            # start a background connection attempt, and track the IAsyncResult
            $iar = $tcpClient.BeginConnect( $computerName, $port, $null, $null )

            # add an asynchronous wait handle with timeout to the iar. this will return true if
            # completed within the time limit, or false if it times out
            $wait = $iar.AsyncWaitHandle.WaitOne( $timeout, $False )

            # check wait handle
            If ( $wait -eq $False )
            {
                # connection attempt timed out
                Return $False
            }

            # connection attempt did not time out - check whether the connection successfully
            # completed by trying to close it
            $error.Clear()
            $tcpClient.EndConnect( $iar ) | Out-Null
            If ( $? -eq $False )
            {
                # EndConnect failed, therefore initial connection was not successful
                $tcpClient.Close()
                Return $False
            }

            Else
            {
                # connection was established and closed successfully, all ok
                $tcpClient.Close()
                Return $True
            }

        }

        Catch { Return $False }

    }

}
