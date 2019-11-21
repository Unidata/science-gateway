<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<html>
<head>
    <title>JSP Redirect</title>
</head>
<body>
    <%
        String redirectURL = "https://ramadda.scigw.unidata.ucar.edu/repository";
        response.sendRedirect(redirectURL);
    %>
</body>
</html>
