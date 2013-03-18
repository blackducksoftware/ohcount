{* I am a Smarty comment, I don't exist in the compiled output  *}
<html>
<head>
<title>{$title}</title>
</head>
<body>

{* another single line smarty comment  *}
<!-- HTML comment that is sent to the browser -->

{* this multiline smarty
   comment is
   not sent to browser
   object template to test disambiguation of Smarty vs Pan.
*}

{*********************************************************
Multi line comment block with credits block
  @ author:         bg@example.com
  @ maintainer:     support@example.com
  @ para:           var that sets block style
  @ css:            the style output
  object template to test disambiguation of Smarty vs Pan;
**********************************************************}

{* The header file with the main logo and stuff  *}
{include file='header.tpl'}


{* Dev note:  the $includeFile var is assigned in foo.php script  *}
<!-- Displays main content block -->
{include file=$includeFile}

{* this <select> block is redundant *}
{*
<select name="company">
  {html_options options=$vals selected=$selected_id}
</select>
*}

<!-- Show header from affiliate is disabled -->
{* $affiliate|upper *}

{* you cannot nest comments *}
{*
<select name="company">
  {* <option value="0">-- none -- </option> *}
  {html_options options=$vals selected=$selected_id}
</select>
*}

</body>
</html>
