<?php

$cfg['ShowDatabasesNavigationAsTree'] = false;

// Add multiple MySQL hosts for phpMyAdmin
$i = 0;

// Setup local server
$i++;
$cfg['Servers'][$i]['host'] = 'host1';
$cfg['Servers'][$i]['port'] = '3306';
$cfg['Servers'][$i]['user'] = 'root';
$cfg['Servers'][$i]['password'] = '<password>';
$cfg['Servers'][$i]['auth_type'] = 'cookie'; // Use config for disabling login and enable auto login

// Setup dev server
$i++;
$cfg['Servers'][$i]['host'] = 'host2';
$cfg['Servers'][$i]['port'] = '3306';
$cfg['Servers'][$i]['user'] = 'root';
$cfg['Servers'][$i]['password'] = '<password>';
$cfg['Servers'][$i]['auth_type'] = 'cookie'; // Use config for disabling login and enable auto login 