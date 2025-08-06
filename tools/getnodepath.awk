# originally written by Simon Hsiao
BEGIN {var[0]="NULL"; intask=0}
$1=="family" { if (intask==1) {intask=0; lev_down()}; lev_up($2) }
$1=="suite"  { if (intask==1) {intask=0; lev_down()}; lev_up($2) }
$1=="endfamily" { if (intask==1) {intask=0; lev_down()}; lev_down() }
$1=="endsuite" { if (intask==1) {intask=0; lev_down()}; lev_down() }
$1=="task" { if (intask==1) {intask=0; lev_down()}; lev_up($2); intask=1 }
$1=="trigger" {var[levmax]=$0; prt()}
function lev_up (name)
{
    ++levmax
    node[levmax]=name
    var[levmax]="NULL"
}
function lev_down ()
{
#    for (level=1; level<=levmax; ++level)
#        printf ("/%s",node[level])
    value="NULL"
#    for (level=1; level<=levmax; ++level)
        if (var[level] != "NULL") value=var[level]
#    printf (" %s",value)
#    printf ("\n")
    var[levmax]="NULL"
    --levmax
}
function prt ()
{
    for (level=1; level<=levmax; ++level)
        printf ("/%s",node[level])
    printf (" %s",var[levmax])
    printf ("\n")
}

