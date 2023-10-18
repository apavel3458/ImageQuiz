
<html>
<head>

    <link rel="stylesheet" href="../admin/admin.css" type="text/css" media="screen">
    <script type="text/javascript" src="../jslib/jquery-1.10.1.min.js"></script>
</head>
<body>

<div class="example">
    <div class="menu">
        <span>
            <ul id="nav">
                <li><a href="#">Home</a></li>
                <li><a href="#">Tutorials</a>
                    <div class="subs">
                        <div>
                            <ul>
                                <li><h3>Submenu #1</h3>
                                    <ul>
                                        <li><a href="#">Link 1</a></li>
                                        <li><a href="#">Link 2</a></li>
                                        <li><a href="#">Link 3</a></li>
                                        <li><a href="#">Link 4</a></li>
                                        <li><a href="#">Link 5</a></li>
                                    </ul>
                                </li>
                                <li><h3>Submenu #2</h3>
                                    <ul>
                                        <li><a href="#">Link 6</a></li>
                                        <li><a href="#">Link 7</a></li>
                                        <li><a href="#">Link 8</a></li>
                                    </ul>
                                </li>
                                <li><h3>Submenu #3</h3>
                                    <ul>
                                        <li><a href="#">Link 9</a></li>
                                        <li><a href="#">Link 10</a></li>
                                    </ul>
                                </li>
                            </ul>
                        </div>
                    </div>
                </li>
                <li><a href="#">Resources</a>
                    <div class="subs">
                        <div class="wrp2">
                            <ul>
                                <li><h3>Submenu #4</h3>
                                    <ul>
                                        <li><a href="#">Link 1</a></li>
                                        <li><a href="#">Link 2</a></li>
                                        <li><a href="#">Link 3</a></li>
                                        <li><a href="#">Link 4</a></li>
                                        <li><a href="#">Link 5</a></li>
                                    </ul>
                                </li>
                                <li><h3>Submenu #5</h3>
                                    <ul>
                                        <li><a href="#">Link 6</a></li>
                                        <li><a href="#">Link 7</a></li>
                                        <li><a href="#">Link 8</a></li>
                                        <li><a href="#">Link 9</a></li>
                                        <li><a href="#">Link 10</a></li>
                                    </ul>
                                </li>
                            </ul>
                            <p class="sep"></p>
                            <ul>
                                <li><h3>Submenu #6</h3>
                                    <ul>
                                        <li><a href="#">Link 11</a></li>
                                        <li><a href="#">Link 12</a></li>
                                        <li><a href="#">Link 13</a></li>
                                    </ul>
                                </li>
                                <li><h3>Submenu #7</h3>
                                    <ul>
                                        <li><a href="#">Link 14</a></li>
                                        <li><a href="#">Link 15</a></li>
                                        <li><a href="#">Link 16</a></li>

                                    </ul>
                                </li>
                                <li><h3>Submenu #8</h3>
                                    <ul>
                                        <li><a href="#">Link 17</a></li>
                                        <li><a href="#">Link 18</a></li>
                                        <li><a href="#">Link 19</a></li>
                                    </ul>
                                </li>
                            </ul>
                        </div>
                    </div>
                </li>
            </ul>
        </span>
    </div>
</div>

<script type="text/javascript">
jQuery(window).load(function() {
	alert("test");
    $("#nav > li > a").click(function (e) { // binding onclick
        if ($(this).parent().hasClass('selected')) {
            $("#nav .selected div div").slideUp(100); // hiding popups
            $("#nav .selected").removeClass("selected");
        } else {
            $("#nav .selected div div").slideUp(100); // hiding popups
            $("#nav .selected").removeClass("selected");

            if ($(this).next(".subs").length) {
                $(this).parent().addClass("selected"); // display popup
                $(this).next(".subs").children().slideDown(200);
            }
        }
        e.stopPropagation();
    }); 

    $("body").click(function () { // binding onclick to body
        $("#nav .selected div div").slideUp(100); // hiding popups
        $("#nav .selected").removeClass("selected");
    }); 

});
</script>

</body>
</html>