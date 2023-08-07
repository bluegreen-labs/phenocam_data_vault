# phenocam data vault

The StarDot internet cameras need a continuous network connection to receive time from an NTP server, while the PhenoCam network relies on a continuous internet connection to transfer data. Many offline sites can't fullfil both requirements. Here, a raspberry pi with a GPS and an NTP server provides both a solution for keeping the StarDot camera clock in sync and receiving images on a storage (USB drive) medium.
