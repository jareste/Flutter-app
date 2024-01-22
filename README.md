# Flutter-app

On this project I was requested to do an android app on my prefered lenguaje to imitate an existing app they provided. As the offer was in flutter I decided to go with it.

The app it's a simple app that's doing api requests to get the products to show. I was also requested to:

- Generate a view for a concret product when clicking on it.
- Add a searchbar.
- Some ways to display as idOrder.
- A way to scan barcodes and search for an specific product.
- Whatever I wanted to add.


I decided to add:

- Favourite's list, it includes a star that comes with each product and its filled if you already starred it and white if you still dont. with an option to see all your products marked as favourites.
- Price display order.


I was thinking on instead of asking the api each time i want to do a search store all the values local and once each day or each X hours i'm searching execute the api petition to prevent the api being down or not having connexion, but i was not able to do it as the only way i found to test was launching the app on a phisical device and then I encountered the issue of needing the api to be https for android policies.