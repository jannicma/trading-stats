import mailtrap as mt

def send_mail(content):
    # create mail object
    mail = mt.Mail(
        sender=mt.Address(email="mailtrap@demomailtrap.com", name="Mailtrap Test"),
        to=[mt.Address(email="jannic.marcon5@gmail.com")],
        subject="trade alarm",
        text=content,
        category="Integration Test",
    )

    # create client and send
    client = mt.MailtrapClient(token="b5ade0b3d7b2af667a01771509ef022a")
    client.send(mail)