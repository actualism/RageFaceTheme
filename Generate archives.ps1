#########################################################################
## Rage Face Theme generation Script
##  Note: this relies on the pidgin files being up-to-date. 
#########################################################################

$source = @"
public class Sorter
{
    public static System.Collections.Generic.SortedDictionary<string, string> GetSortedDictionary (System.Collections.Generic.Dictionary<string, string> unsorted)
    {
        return new System.Collections.Generic.SortedDictionary<string, string>(unsorted, new StringLengthComparer());
    }
}

public class StringLengthComparer : System.Collections.Generic.IComparer<string>
    {
        public int Compare(string x, string y)
        {
            // <0 -> x<y
            // =0 -> x=y
            // >0 -> x>y

            if (x.Length == y.Length)
                return x.CompareTo(y);
            if (x.Length > y.Length)
                return -1;
            if (x.Length < y.Length)
                return 1;

            return 1;
        }
    }
"@

Import-Module Pscx

Add-Type -TypeDefinition $source

# Helper function from http://blogs.msdn.com/b/powershell/archive/2007/06/19/get-scriptdirectory.aspx

$Invocation = (Get-Variable MyInvocation -Scope 0).Value
$pwd = Split-Path $Invocation.MyCommand.Path
Set-Location $pwd

# Helper function from http://gallery.technet.microsoft.com/scriptcenter/10f2a1e3-cbd6-4d62-a196-22b943884d50

function Exists-Dir($path) {
    if (Test-Path $path -pathType container) 
    { 
        return $true; 
    } 
    else 
    { 
        return $false; 
    } 
}

function Exists-File($path) {
    if(Test-Path $path)
    {
        return $true;
    }
    else
    {
        return $false;
    }
}

# Clear the generated folders first... if they exist!

if (Exists-Dir("RageFace.colloquyEmoticons\Contents\Resources"))
{
    Remove-Item RageFace.colloquyEmoticons\Contents\Resources\*
}
else
{
    New-Item RageFace.colloquyEmoticons\Contents\Resources -type directory    
}

if (Exists-Dir("xml"))
{
    Remove-Item xml\*
}
else
{
    New-Item xml -type directory
}

if (Exists-Dir("php"))
{
    Remove-Item php\*
}
else
{
    New-Item php -type directory
}

if (Exists-Dir("adium\RageFaces.AdiumEmoticonset"))
{
    Remove-Item adium\RageFaces.AdiumEmoticonset\*
}
else
{
    New-Item adium\RageFaces.AdiumEmoticonset -type directory
}

# Ensure all files are lowercase first.

$files=get-childitem troll -recurse
foreach ($file in $files)
{
    # don't rename the readme; I like it to be all caps.
    if (($file.extension -cne "") -and ($file.name -cne $file.name.ToLower()))
    {
        Rename-Item $file.fullname $file.fullname.ToLower()
    }
}

if(!(Exists-File(Join-Path $pwd "RageFace.colloquyEmoticons\Contents\Resources\menu.plist")))
{
    New-Item (Join-Path $pwd "RageFace.colloquyEmoticons\Contents\Resources\menu.plist") -type file
}
$menuplist = [System.IO.StreamWriter] (Join-Path $pwd "RageFace.colloquyEmoticons\Contents\Resources\menu.plist")
$menuplist.WriteLine("(")

if(!(Exists-File(Join-Path $pwd "RageFace.colloquyEmoticons\Contents\Resources\emoticons.plist")))
{
    New-Item (Join-Path $pwd "RageFace.colloquyEmoticons\Contents\Resources\emoticons.plist") -type file
}
$emoticonsplist = [System.IO.StreamWriter] (Join-Path $pwd "RageFace.colloquyEmoticons\Contents\Resources\emoticons.plist")
$emoticonsplist.WriteLine("{")

if(!(Exists-File(Join-Path $pwd "RageFace.colloquyEmoticons\Contents\Resources\emoticons.css")))
{
    New-Item (Join-Path $pwd "RageFace.colloquyEmoticons\Contents\Resources\emoticons.css") -type file
}
$emoticonscss =  [System.IO.StreamWriter] (Join-Path $pwd "RageFace.colloquyEmoticons\Contents\Resources\emoticons.css")
$emoticonscss.WriteLine(".emoticon samp { display:none; }")
$emoticonscss.WriteLine(".emoticon:after { vertical-align: -25%; }")

if(!(Exists-File(Join-Path $pwd "adium\RageFaces.AdiumEmoticonset\Emoticons.plist")))
{
    New-Item (Join-Path $pwd "adium/RageFaces.AdiumEmoticonset\Emoticons.plist") -type file
}
$adiumOutput = [System.IO.StreamWriter] (Join-Path $pwd "adium/RageFaces.AdiumEmoticonset\Emoticons.plist")
$adiumOutput.WriteLine("<?xml version='1.0' encoding='UTF-8'?>")
$adiumOutput.WriteLine("<!DOCTYPE plist PUBLIC '-//Apple Computer//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'>")
$adiumOutput.WriteLine("<plist version='1.0'>")
$adiumOutput.WriteLine("<dict>")
$adiumOutput.WriteLine("<key>AdiumSetVersion</key>")
$adiumOutput.WriteLine("<integer>1</integer>")
$adiumOutput.WriteLine("<key>Emoticons</key>")
$adiumOutput.WriteLine("<dict>")

if(!(Exists-File(Join-Path $pwd "xml\ragefaces.xml")))
{
    New-Item (Join-Path $pwd "xml\ragefaces.xml") -type file
}
$xmlOutput = [System.IO.StreamWriter] (Join-Path $pwd "xml\ragefaces.xml")
$xmlOutput.WriteLine("<?xml version='1.0' encoding='UTF-8'?>")
$xmlOutput.WriteLine("<rageFaces>")

if(!(Exists-File(Join-Path $pwd "php\faces.php")))
{
    New-Item (Join-Path $pwd "php\faces.php") -type file
}
$phpFaces = [System.IO.StreamWriter] (Join-Path $pwd "php\faces.php")
$phpFaces.WriteLine("<?php")
$phpFaces.WriteLine('function smiley($quote) {')
$phpFaces.WriteLine("")

$phpCodeArray = New-Object -TypeName "System.Text.StringBuilder"
[void]$phpCodeArray.AppendLine('$code = array();')

$phpImageArray = New-Object -TypeName "System.Text.StringBuilder"
[void]$phpImageArray.AppendLine('$img = array();')

$linecount = 0

$faces = New-Object -TypeName "System.Collections.Generic.Dictionary[String,String]"

Get-Content "troll\theme" | Foreach-Object {
    if ($linecount -gt 5)
    { 
        $Tokens = $_.Split(" ")
        # first is the filename, last is the token
        
        $token = $Tokens[$Tokens.Length - 1]
        $filename = $Tokens[0]
        
        $faces.Add($token, $filename)
    }
    $linecount = $linecount+1
}

$sfaces = [Sorter]::GetSortedDictionary($faces)

# Debug output
ForEach ($face in $sfaces.GetEnumerator())
{
    "token=" + $face.Key + " filename=" + $face.Value
}

$counter = 0

ForEach ($face in $sfaces.GetEnumerator()) {
    # menu.plist example:  {name = ":( - frown"; image="frown.gif"; insert=":(";},
    $menuplist.Write("  {name = `"")
    
    # $Tokens = $_.Split(" ")
    # first is the filename, last is the token
    
    # $token = $Tokens[$Tokens.Length - 1]
    # $filename = $Tokens[0]
    
    $token = $face.Key
    $filename = $face.Value
    
    $menuplist.Write($token)
    
    $menuplist.Write("`"; image = `"")
    $menuplist.Write($filename)
    
    $menuplist.Write("`"; insert = `"")
    $menuplist.Write($token)
    
    $menuplist.WriteLine("`";},")
    
    # emoticons.plist example:   frowngif = (":(");
    
    $emoticonsplist.Write("  ")
    
    $tokenWithoutColon = $token.Replace(":", "")
    
    $emoticonsplist.Write($tokenWithoutColon)
    $emoticonsplist.Write(" = (`"");
    $emoticonsplist.Write($token)
    $emoticonsplist.WriteLine("`");")
    
    # emoticons.css example: .emoticon.frowngif:after{ content: url("frown.gif"); }
    
    $emoticonscss.Write(".emoticon.")
    $emoticonscss.Write($tokenWithoutColon)
    $emoticonscss.Write(":after{ content: url(`"")
    $emoticonscss.Write($filename)
    $emoticonscss.WriteLine("`"); }")
        
    # build Adium's XML file
        
    $adiumOutput.Write("<key>")
    $adiumOutput.Write($filename)
    $adiumOutput.WriteLine("</key>")
    $adiumOutput.WriteLine("<dict>")
    $adiumOutput.WriteLine("<key>Equivalents</key>")
    $adiumOutput.WriteLine("<array>")
    $adiumOutput.Write("<string>")
    $adiumOutput.Write($tokenWithoutColon)
    $adiumOutput.WriteLine("</string>")
    $adiumOutput.WriteLine("<key>Name</key>")
    $adiumOutput.Write("<string>")
    $adiumOutput.Write($tokenWithoutColon)
    $adiumOutput.WriteLine("</string>")
    $adiumOutput.WriteLine("</dict>")
    
    # build the XML file
    
    $xmlOutput.WriteLine("<face>")
    $xmlOutput.Write("<name>")
    $xmlOutput.Write($tokenWithoutColon)
    $xmlOutput.WriteLine("</name>")
    
    $xmlOutput.Write("<file>")
    $xmlOutput.Write($filename)
    $xmlOutput.WriteLine("</file>")
    $xmlOutput.WriteLine("</face>")
    
    # And the php file too
    
    # example line for code: $code[0] = "/:tdad/";
    [void]$phpCodeArray.Append('$code[')
    [void]$phpCodeArray.Append($counter)
    [void]$phpCodeArray.Append("] = ""/")
    [void]$phpCodeArray.Append($token)
    [void]$phpCodeArray.AppendLine("/"";")
    
    # example line for image: $img[56] = "<img src=\"troll/smile2.png\" alt=\"!smile\" />";
    [void]$phpImageArray.Append('$img[')
    [void]$phpImageArray.Append($counter)
    [void]$phpImageArray.Append('] = "<img src=\"troll/')
    [void]$phpImageArray.Append($filename)
    [void]$phpImageArray.Append('\" alt=\"!')
    [void]$phpImageArray.Append($tokenWithoutColon)
    [void]$phpImageArray.AppendLine('\" />";')
    
    $counter = $counter + 1
}

$menuplist.WriteLine(")")
$menuplist.close()

$emoticonsplist.WriteLine("}")
$emoticonsplist.Close()

$emoticonscss.WriteLine("")
$emoticonscss.Close()

$adiumOutput.WriteLine("</dict>")
$adiumOutput.WriteLine("</dict>")
$adiumOutput.WriteLine("</plist>")
$adiumOutput.Close()

$xmlOutput.WriteLine("</rageFaces>")
$xmlOutput.Close()

$phpFaces.WriteLine($phpCodeArray.ToString())
$phpFaces.WriteLine($phpImageArray.ToString())

$phpFaces.WriteLine("")
$phpFaces.WriteLine('  return preg_replace($code, $img, $quote);')
$phpFaces.WriteLine("")
$phpFaces.WriteLine("}")
$phpFaces.WriteLine("?>")

$phpFaces.Close()

# Copy the faces from the Pidgin dir to the colloquy and adium dirs

Copy-Item troll\*.png RageFace.colloquyEmoticons\Contents\Resources -force
Copy-Item troll\*.gif RageFace.colloquyEmoticons\Contents\Resources -force
Copy-Item troll\*.jpg RageFace.colloquyEmoticons\Contents\Resources -force

Copy-Item troll\*.png adium\RageFaces.AdiumEmoticonset -force
Copy-Item troll\*.gif adium\RageFaces.AdiumEmoticonset -force
Copy-Item troll\*.jpg adium\RageFaces.AdiumEmoticonset -force

# ZIP ZE FILEZ

Write-Zip adium/RageFaces.AdiumEmoticonset RageFaces.AdiumEmoticonset.zip -Quiet
Write-Zip troll troll-pidgin.zip -Quiet
Write-Zip RageFace.colloquyEmoticons troll-colloquy.zip -Quiet