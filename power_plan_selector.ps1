#####  This section simply gets rid of the PS window when you start the application  #####

$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

##########################################################################################



#####  This is the actual code for presenting the GUI with buttons  #####
Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        Title="Power Setting" Height="200" Width="200">
    <Grid HorizontalAlignment="Center" Height="180" VerticalAlignment="Center" Width="180">
        <Grid.RowDefinitions>
            <RowDefinition/>
            <RowDefinition/>
            <RowDefinition/>
        </Grid.RowDefinitions>
        <Button x:Name="power_saver" Grid.Column="0" Grid.Row="0" Content="Power Saver" Width="100" Height="25"/>
        <Button x:Name="balanced" Grid.Column="0" Grid.Row="1" Content="Balanced" Width="100" Height="25"/>
        <Button x:Name="high_perf" Grid.Column="0" Grid.Row="2" Content="High Performance" Width="100" Height="25"/>
    </Grid>
</Window>
"@
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

#####  This defines how the buttons interact  #####
$power_saver = $window.FindName("power_saver")
$balanced = $window.FindName("balanced")
$high_perf = $window.FindName("high_perf")


#####  This looks up your profile for each default windows power setting
#####  This then finds the GUID string of said profile
#####  This then runs the powercfg executable with an argument for the GUID you selected

$power_saver.Add_Click({
    $power_saver_string = (powercfg /L | Select-String -Pattern "Power Saver").tostring()
    $power_saver_guid = $power_saver_string.Substring(19,36)
    powercfg.exe -SETACTIVE $power_saver_guid
})

$balanced.Add_Click({
    $balanced_string = (powercfg /L | Select-String -Pattern Balanced).tostring()
    $balanced_guid = $balanced_string.Substring(19,36)
    powercfg.exe -SETACTIVE $balanced_guid
})

$high_perf.Add_Click({
    $high_perf_string = (powercfg /L | Select-String -Pattern "High Performance").tostring()
    $high_perf_guid = $high_perf_string.Substring(19,36)
    powercfg.exe -SETACTIVE $high_perf_guid
})

$window.ShowDialog()
