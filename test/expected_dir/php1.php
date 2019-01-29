html	code	<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
html	code	                      "http://www.w3.org/TR/html4/strict.dtd">
html	code	<html>
html	code		<head>
html	code			<script type="text/javascript">
javascript	comment			// javascript comment
javascript	code			document.write("Hello World!")
html	code			</script>
html	code			<style type="text/css">
css	comment			/* css comment */
css	code			h1 {
css	code				color: black;
css	code			}
html	code			</style>
html	code		</head>
html	code		<body>
html	code		<table cellSpacing=1 cellPadding=2 bgColor=black border=0>
html	code		<tr bgColor=white>
html	code		<td>First</td>
html	code		<td>Last</td>
html	code		<td>Email<td>
html	code		</tr>
html	code		</table>
html	blank	
php	code	<?php
php	comment	## Comment with a hash symbol ##
php	code		mysql_connect("localhost", "db user", "db pass")
php	code		or die("DB CONNECT ERROR: " . mysql_error());
php	blank	
php	code		mysql_select_db("db name")
php	code		or die("DB SELECT ERROR: " . mysql_error());
php	blank	
php	code		$query = "SELECT fname, lname, email FROM table ORDER BY lname";
php	blank	
php	code		$result = mysql_query($query)
php	code		or die("DB SELECT ERROR: " . mysql_error());
php	blank	
php	code		while($row = mysql_fetch_array($result))
php	code		{
php	code			$lname = $row['lname'];
php	code			$fname = $row['fname'];
php	code			$email = $row['email'];
php	blank	
php	comment			// Spaghetti code starts....(slopping html code in)
php	code	>
html	blank	
html	code		<tr bgColor=white>
php	code		<td><?=$fname?></td>
php	code		<td><?=$lname?></td>
php	code		<td><?=$email?><td>
html	code		</tr>
html	code		</table>
html	blank	
php	code	<?
php	code		} // end while
php	comment		// Spaghetti code is both a source of praise and complaints
php	code	>
html	blank	
html	code	</body>
