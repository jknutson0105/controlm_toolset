#!/bin/bash
#
#Copyright 2021 BMC Software, Inc.
#
# Permission to use, copy, modify, and/or distribute this software for any purpose
# with or without fee is hereby granted, provided that the above copyright notice 
# and this permission and disclaimer notices appear in all copies.
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH 
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND 
# FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, 
# OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, 
# DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS 
# ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
# BMC SOFTWARE DOES NOT PROVIDE SUPPORT OR DOCUMENTATION FOR THIS SOFTWARE.
# USAGE OF ALL OR PART OF THIS SOFTWARE IMPLIES ACCEPTANCE OF THESE TERMS.
#
# Export definitions from Helix Control-M into JSON files
#
# Author  : David Fernandez (david_fernandez@bmc.com)
# Version : 1.0 (08/06/2021)
#
# Usage : ctm_export_all.sh [ctm-environment]
# Notes : - requires Automation API CLI installed and Environments configured
#         - when passing no parameters, it uses the default Environment
#

# Assign Environment
if [ $# -eq 0 ] ; then ctmenv=`ctm env show | grep current | cut -d " " -f 3`
else ctmenv=$1
fi

# Check if Environment exists and is working
ctm config servers::get -e $ctmenv > /dev/null 2>&1
if [ $? -eq 0 ] ; then echo Exporting definitions from Control-M Environment = $ctmenv
else echo ERROR : Control-M Environment $ctmenv does not exist or is not accesible & exit 1
fi

# Create export directory
exportdate=`date +%Y%m%d`
exportdir="$ctmenv"_$exportdate
mkdir $exportdir > /dev/null 2>&1

check_status()
{
   if [ $1 -eq 0 ] ; then
      echo OK : export successful for $object
   else
      echo ERROR : export for $object failed - check output file for details
      mv $exportdir/$object.json $exportdir/$object.error
   fi
}

# Export Folders and Jobs
object=jobs
ctm deploy jobs::get -s "ctm=*&folder=*" -e $ctmenv > $exportdir/$object.json 2>&1
check_status $?

# Export Calendars
object=calendars
ctm deploy calendars::get -e $ctmenv > $exportdir/$object.json 2>&1
check_status $?

# Export Centralized Connection Profiles
object=CCPs
ctm deploy connectionprofiles:centralized::get -s "type=*&name=*" -e $ctmenv > $exportdir/$object.json 2>&1
check_status $?

# Export Resource Pools
object=resource-pools
ctm run resources::get -e $ctmenv > $exportdir/$object.json 2>&1
check_status $?

# Export Resource Pool definitions
mkdir $exportdir/$object > /dev/null 2>&1
list=`cat $exportdir/$object.json | grep \"name\" | cut -d "\"" -f4`
for i in $list ; do
   ctm run resources::get -s "name=$i" -e $ctmenv > $exportdir/$object/$i.json 2>&1
done
echo OK : export successful for resource-pool definitions

# Export User list
object=users
ctm config authorization:users::get -e $ctmenv > $exportdir/$object.json 2>&1
check_status $?

# Export User definitions
mkdir $exportdir/$object > /dev/null 2>&1
list=`cat $exportdir/$object.json | grep \"name\" | cut -d "\"" -f4`
for i in $list ; do
   ctm config authorization:user::get $i -e $ctmenv > $exportdir/$object/$i.json 2>&1
done
echo OK : export successful for user definitions

# Export Role list
object=roles
ctm config authorization:roles::get -e $ctmenv > $exportdir/$object.json 2>&1
check_status $?

# Export Role definitions
mkdir $exportdir/$object > /dev/null 2>&1
list=`cat $exportdir/$object.json | grep \"name\" | cut -d "\"" -f4`
for i in $list ; do
   ctm config authorization:role::get $i -e $ctmenv > $exportdir/$object/$i.json 2>&1
done
echo OK : export successful for role definitions

# Export Agents
object=agents
ctm config server:agents::get IN01 -e $ctmenv > $exportdir/$object.json 2>&1
check_status $?

# Export Hostgroups
object=hostgroups
ctm config server:hostgroups::get IN01 -e $ctmenv > $exportdir/$object.json 2>&1
check_status $?

# Export Hostgroup definitions
mkdir $exportdir/$object > /dev/null 2>&1
list=`cat $exportdir/$object.json | grep \" | cut -d "\"" -f2`
for i in $list ; do
   ctm config server:hostgroup:agents::get IN01 $i -e $ctmenv > $exportdir/$object/$i.json 2>&1
done
echo OK : export successful for hostgroup definitions

# Export System Settings
object=system-settings
ctm config systemsettings::get -e $ctmenv > $exportdir/$object.json 2>&1
check_status $?

# Export Secrets list
object=secrets
ctm config secrets::get -e $ctmenv > $exportdir/$object.json 2>&1
check_status $?

echo "Done! >> check results in directory $exportdir"
