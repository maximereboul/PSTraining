function Export-ADUser
{
    Param ([String]$identity)

    $ErrorActionPreference = 'Stop'
    Try {

        $User = Get-ADUser -identity $identity

        if ($User.Mail) {
            '{0} {1} <{2}>' -f $User.Surname, $User.Name, $User.Mail
        }
        else {
            '{0} {1}' -f $User.SurName, $User.Name
        }
    }
    Catch {
        throw 'USER NOT FOUND'
    }
}