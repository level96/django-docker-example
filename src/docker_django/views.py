from django.http import HttpResponse


async def pong(request):
    return HttpResponse(f'aaaaa you say: {request.GET.get("say")}, i say pong')
