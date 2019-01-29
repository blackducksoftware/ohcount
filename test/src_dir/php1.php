<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
                      "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<script type="text/javascript">
		// javascript comment
		document.write("Hello World!")
		</script>
		<style type="text/css">
		/* css comment */
		h1 {
			color: black;
		}
		</style>
	</head>
	<body>
	<table cellSpacing=1 cellPadding=2 bgColor=black border=0>
	<tr bgColor=white>
	<td>First</td>
	<td>Last</td>
	<td>Email<td>
	</tr>
	</table>

<?php
## Comment with a hash symbol ##
	mysql_connect("localhost", "db user", "db pass")
	or die("DB CONNECT ERROR: " . mysql_error());

	mysql_select_db("db name")
	or die("DB SELECT ERROR: " . mysql_error());

	$query = "SELECT fname, lname, email FROM table ORDER BY lname";

	$result = mysql_query($query)
	or die("DB SELECT ERROR: " . mysql_error());

	while($row = mysql_fetch_array($result))
	{
		$lname = $row['lname'];
		$fname = $row['fname'];
		$email = $row['email'];

		// Spaghetti code starts....(slopping html code in)
?>

	<tr bgColor=white>
	<td><?=$fname?></td>
	<td><?=$lname?></td>
	<td><?=$email?><td>
	</tr>
	</table>

<?
	} // end while
	// Spaghetti code is both a source of praise and complaints
?>

</body>
