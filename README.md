# Project 1 - *Flicks*

**Flicks** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **9** hours spent in total

## User Stories

The following **required** functionality is complete:

- [x] User can view a list of movies currently playing in theaters from The Movie Database.
- [x] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [x] User sees a loading state while waiting for the movies API.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [ ] User sees an error message when there's a networking error. 
- [x] Movies are displayed using a CollectionView instead of a TableView.
- [ ] User can search for a movie.
- [ ] All images fade in as they are loading.
- [x] Customize the UI.

The following **additional** features are implemented:

- [x] Added more movie data to the detail view (rating, release date, number of voters)

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/o8D7Dfy.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Challenges: Dealing with Networking Errors (still need to improve), and formatting navigation controller shadow. I'll make more changes soon!

## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

# Project 2 - *Flicks*

**Flicks** is a movies app displaying box office and top rental DVDs using [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **<1** hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] User can view movie details by tapping on a cell.
- [x] User can select from a tab bar for either **Now Playing** or **Top Rated** movies.
- [x] Customize the selection effect of the cell.

The following **optional** features are implemented:

- [ ] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [ ] Customize the navigation bar.

The following **additional** features are implemented:

- [x] Customized tab bar (Upcoming/My Flicks)
- [x] Detail View with movie poster, image, rating, reviews, genre, number of ratings, similar movies, and cast photos using collectionview
- [x] Save your favorite movies to My Flicks, for easy access
- [x] Click on similar (movies or movies in My Flicks) to see more details
- [x] View YouTube trailer, if available
- [x] Display placeholder for unavailable images
- [x] Shorten scrollview if similar movies not available

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Customizing the navigation bar - if I had more time, a search bar and a tab for movie/tv endpoints would replace the default navbar for the first three tabs.
2. Facebook integration - I have worked with Facebook integration for webapps before, so I'm sure it would not be a far stretch to weave it into an application. Flicks might benefit from fb integration by enabling users to share their favorite movies, or see an activity feed containing movie-related statuses from their friends (or activity from within the app).

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/jikYn3G.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

The biggest challenge for me was working with unreliable data. APIs often return unpredictable data (ex: Similar movies, reviews, and cast photos are not always available), and it was a new challenge for me to make my code dynamic enough to handle such cases.

## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
