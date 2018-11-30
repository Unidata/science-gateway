<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<html>
<head>
    <title>JSP Redirect</title>
</head>
<body>
    <%
        String redirectURL = "http://thredds-jetstream.unidata.ucar.edu/thredds/catalog.html";
        response.sendRedirect(redirectURL);
    %>
</body>
</html>
