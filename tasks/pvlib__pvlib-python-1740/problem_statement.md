Update CAMS/SoDa URL
SoDa has developed a new load-balancing solution, such that requests are automatically redirected to the fastest server. This means that it might be advisable for us to update the URL in the [``pvlib.iotools.get_cams``](https://pvlib-python.readthedocs.io/en/stable/reference/generated/pvlib.iotools.get_cams.html?highlight=get_cams#pvlib.iotools.get_cams) function. 

Email from SoDa (March 7th, 2023):
> Our beta load balancing system for SoDa/CAMS API requests is extended to March 13th. All requests made on the beta-api.soda-solardata.com WILL NOT BE COUNTED in your subscription. The beta access will last until then. **From March 14th, the service will be fully operational and you have to use api.soda-solardata.com to process your API (machine to machine) requests.**

and email from February 22nd, 2023:
> This new functionality will automatically redirect any request to the fastest available SoDa server. As a result, future updates/maintenances won't need any action from your part as server switches will be completely autonomous.

I will be following up on this issue in a couple of weeks.

*Edit: email from March 20th, 2023*
> We strongly advise you to switch your automatic commands on the load balancing system (api.soda-solardata.com). In that way, all future updates won't need any actions from your side. 
