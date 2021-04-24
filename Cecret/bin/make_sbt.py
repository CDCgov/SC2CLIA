import csv

## Rules
# Email contains @; email contains .com, .gov, .edu; email
# Country name must be approved. i.e. USA / United States of America but not US or U.S.A.
# Middle initial can be lower/upper, and w or w/o a period, but must be w/ periods if multiple letters
# >1 Sequence author allowed
# If pub status == in-press, then journal title and year are required, volume, issue, pages_from, pages_to are optional
# If not Reference authors , then Reference author(s) <- Sequence author(s)
def print_contact(first_contact, last_contact, middle_contact, initials_contact,
                  suffix_contact, title_contact, email, org, dept, phone, fax,
                  street, city, state, zip, country):
    print("""
Submit-block ::= {{
  contact {{
    contact {{
      name name {{
        last "{0}",
        first "{1}",
        middle "{2}",
        initials "{3}",
        suffix "{4}",
        title "{5}"
      }},
      affil std {{
        affil "{6}",
        div "{7}",
        city "{8}",
        sub "{9}",
        country "{10}",
        street "{11}",
        email "{12}",
        postal-code "{13}"
      }}
    }}
  }},
    cit {{
    authors {{
      names std {{""".format(last_contact, first_contact, middle_contact, initials_contact, suffix_contact, title_contact, org, dept, city, state, country, street, email, zip))

def print_name(first_contact_a, last_contact_a, middle_contact_a, initial_contact_a, suffix_contact_a, title_contact_a):
    print("""
        {{
          name name{{
            last "{0}",
            first "{1}",
            middle "{2}",
            initials "{3}",
            suffix "{4}",
            title "{5}"
            }}
        }}""".format(first_contact_a, last_contact_a, middle_contact_a, initial_contact_a, suffix_contact_a, title_contact_a)
    )

def print_rest():
    print("""
      },
      affil std {
        affil "CDC",
        div "RVB",
        city "Atlanta",
        sub "GA",
        country "USA",
        street "1600 Clifton Road",
        postal-code "30329"
      }
    }
  },
  subtype new
}
Seqdesc ::= pub {
  pub {
    gen {
      cit "unpublished",
      authors {
        names std {
          {
            name name {
              last "LastAuthorOne",
              first "FirstAuthorOne",
              middle "",
              initials "",
              suffix "",
              title ""
            }
          }
        }
      },
      title "Reference Title"
    }
  }
}
Seqdesc ::= user {
  type str "Submission",
  data {
    {
      label str "AdditionalComment",
      data str "ALT EMAIL:Email@cdc.gov"
    }
  }
}
Seqdesc ::= user {
  type str "Submission",
  data {
    {
      label str "AdditionalComment",
      data str "Submission Title:None"
    }
  }
}""")

with open('submission_template.csv', newline='') as csvfile:
    reader = csv.DictReader(csvfile, delimiter=",")
    for row in reader:
        first_contact = row['first_contact']
        last_contact = row['last_contact']
        middle_contact = row['middle_contact']
        initials_contact = row['initials_contact']
        suffix_contact = row['suffix_contact']
        title_contact = row['title_contact']
        email = row['email']
        org = row['org']
        dept = row['dept']
        phone = row['phone']
        fax = row['fax']
        street = row['street']
        city = row['city']
        state = row['state']
        zip = row['zip']
        country = row['country']
        print_contact(first_contact, last_contact, middle_contact, initials_contact,
                      suffix_contact, title_contact, email, org, dept, phone, fax,
                      street, city, state, zip,country)
        
# def isLast(itr):
#   old = itr.next()
#   for new in itr:
#     yield False, old
#     old = new
#   yield True, old

with open('author_template.csv', newline='') as csvfile:
  count = len(csvfile.readlines())

with open('author_template.csv', newline='') as csvfile:
    reader = csv.DictReader(csvfile, delimiter=",")
    for row in reader:
        count -= 1
        first_contact_a = row['first_author']
        last_contact_a = row['last_author']
        middle_contact_a = row['middle_author']
        initial_contact_a = row['initials_author']
        suffix_contact_a = row['suffix_author']
        title_contact_a = row['title_author']
        print_name(first_contact_a, last_contact_a, middle_contact_a,
                   initial_contact_a, suffix_contact_a, title_contact_a)
        # print(count)
        if count > 1:
          print(",")
print_rest()
