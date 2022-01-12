# -*- coding: utf-8 -*-
"""
Created on Wed Nov 10 18:33:40 2021

@author: kange
"""

import tweepy
import pandas as pd

# getting the tweets

# input the keys (removed due to confidentiality)
consumer_key = "" 
consumer_secret ="" 
access_token = "" 
access_token_secret = "" 

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth)

coordinates = ''
language = 'en'
# result_type = 'recent'
# change until_date each time to reflect the date (within 7 days)
until_date = '2021-11-15'
max_tweets = 150
query = 'inflation+outlook -filter:retweets'

tweets = tweepy.Cursor(api.search_tweets, q = query, geocode=coordinates, lang=language, until = until_date, count = 100).items(max_tweets)
tweets_list = [[tweet.text, tweet.created_at, tweet.id_str, tweet.favorite_count, tweet.user.screen_name, tweet.user.id_str, 
                tweet.user.location, tweet.user.url, tweet.user.verified, tweet.user.followers_count, tweet.user.friends_count, tweet.user.statuses_count, tweet.user.default_profile_image, 
                tweet.lang] for tweet in tweets] 

tweets_df = pd.DataFrame(tweets_list, columns = ['tweet', 'time', 'tweet_id', 'fav_count', 'username', 'user_id', 'user_loc', 'tweet_url', 'verified_user', 'user_followers', 
                                                 'user_friends', 'user_status_count', 'prof_image', 'tweet_language'])


### Getting the tweets, limit to how many we can get per period 15min interval ###

# Nov. 2
tweets_df.to_csv('nov_2_tweet.csv', index=False)

#just_tweets = tweets_df['tweet']
#just_tweets = [tw for tw in just_tweets if tw!='']
#combine = ' '.join(just_tweets)

# Nov. 3
tweets_df.to_csv('nov_3_tweet.csv', index=False)

# Nov. 4
tweets_df.to_csv('nov_4_tweet.csv', index=False)

# Nov. 5
tweets_df.to_csv('nov_5_tweet.csv', index=False)

# Nov. 6
tweets_df.to_csv('nov_6_tweet.csv', index=False)

# Nov. 7
tweets_df.to_csv('nov_7_tweet.csv', index=False)

# Nov. 8
tweets_df.to_csv('nov_8_tweet.csv', index=False)

# Nov. 9
tweets_df.to_csv('nov_9_tweet.csv', index=False)

# Nov. 10
tweets_df.to_csv('nov_10_tweet.csv', index=False)

# Nov. 11
tweets_df.to_csv('nov_11_tweet.csv', index=False)

# Nov. 12
tweets_df.to_csv('nov_12_tweet.csv', index=False)

# Nov. 13
tweets_df.to_csv('nov_13_tweet.csv', index=False)

# Nov. 14
tweets_df.to_csv('nov_14_tweet.csv', index=False)


#### JOIN ALL DFS -> MAKE WORDCLOUD ####
nov_2 = pd.read_csv('nov_2_tweet.csv')
nov_3 = pd.read_csv('nov_3_tweet.csv')
nov_4 = pd.read_csv('nov_4_tweet.csv')
nov_5 = pd.read_csv('nov_5_tweet.csv')
nov_6 = pd.read_csv('nov_6_tweet.csv')
nov_7 = pd.read_csv('nov_7_tweet.csv')
nov_8 = pd.read_csv('nov_8_tweet.csv')
nov_9 = pd.read_csv('nov_9_tweet.csv')
nov_10 = pd.read_csv('nov_10_tweet.csv')
nov_11 = pd.read_csv('nov_11_tweet.csv')
nov_12 = pd.read_csv('nov_12_tweet.csv')
nov_13 = pd.read_csv('nov_13_tweet.csv')
nov_14 = pd.read_csv('nov_14_tweet.csv')

all_tweets = pd.concat([nov_2, nov_3, nov_4, nov_5, nov_6, nov_7, nov_8, nov_9, nov_10, nov_11, nov_12, nov_13, nov_14])

# write it to a csv file (can update above code to add more tweets)
all_tweets.to_csv('all_tweets.csv', index=False)

# read in
all_tweets = pd.read_csv('all_tweets.csv')

# Filter for tweets with unique tweet ids
all_tweets = all_tweets.drop_duplicates(subset = ['tweet_id'])


# grab just the tweets
tweets_only = all_tweets['tweet']
tweets_only = [tw for tw in tweets_only if tw!='']
combine = ' '.join(tweets_only)



# Process the text
import nltk
from nltk.tokenize import sent_tokenize, word_tokenize
nltk.download('stopwords')
nltk.download('wordnet')
from nltk.corpus import stopwords
import string
from nltk.tokenize import word_tokenize
from nltk.stem.porter import PorterStemmer
from nltk.stem.wordnet import WordNetLemmatizer

stop = set(stopwords.words('english'))

exclude = set(string.punctuation)
lemma = WordNetLemmatizer()
ps=PorterStemmer()

def clean2(doc):
    stop_free = " ".join([i for i in doc.lower().split() if i not in stop])
    numb_free = ''.join([i for i in stop_free if not i.isdigit()])
    punc_free = ''.join(ch for ch in numb_free if ch not in exclude)
    normalized = " ".join(ps.stem(word) for word in punc_free.split())
    return normalized

tweet_clean = [clean2(doc).split() for doc in tweets_only]

from collections import Counter
word_list = [item for sublist in tweet_clean for item in sublist]
diction=Counter(word_list)
diction.most_common(10)

from wordcloud import WordCloud 
import matplotlib.pyplot as plt 
import numpy as np

Most_common=[word for word, val in diction.most_common(10)] 
val_common=[val for word, val in diction.most_common(10)] 

# bar plot
def plot_bar_x():
    # this is for plotting purpose
    index = np.arange(len(Most_common)) #np.arrange() Return evenly spaced values within a given interval.
    plt.bar(index, val_common)
    plt.xlabel('Most common word', fontsize=10)
    plt.ylabel('Frequency', fontsize=10)
    plt.xticks(index, Most_common, fontsize=10, rotation=30)
    plt.title('Most common words in our corpus')
    plt.show()
plot_bar_x()

flat_string=" ".join([i for i in word_list])

wordcloud = WordCloud(width = 800, height = 800, 
                background_color ='white',  
                min_font_size = 10).generate(flat_string) 

# plot the WordCloud image

# this is what's on consumer's minds right now, and will guide which variables we include in our ML model                        
plt.figure(figsize = (8, 8)) #plt.figure() Create a new figure, or activate an existing figure.
plt.imshow(wordcloud) #plt.imshow() Display an image
plt.axis("off") #Avoid to display axis. (try without to see)
plt.show() 

