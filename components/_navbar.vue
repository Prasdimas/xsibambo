<template>
    <v-card
      class="mx-auto"
      width="300"
    >
      <v-list>
        
  
        <v-list-group
          prepend-icon="account_circle"
          value="true"
        >
          <template v-slot:activator>
            <v-list-item-title>Join Us</v-list-item-title>
          </template>
  
          <v-list-group
            no-action
            sub-group
            value="true"
          >
            <template v-slot:activator>
              <v-list-item-content>
                <v-list-item-title>Become a Loan Officer</v-list-item-title>
              </v-list-item-content>
            </template>
  
            <v-list-item
              v-for="(becomeLO, i) in becomeLOs"
              :key="i"
              link
            >
              <v-list-item-title v-text="becomeLO[0]"></v-list-item-title>
              <v-list-item-icon>
                <v-icon v-text="becomeLO[1]"></v-icon>
              </v-list-item-icon>
            </v-list-item>
          </v-list-group>
  
          <v-list-group
            sub-group
            no-action
          >
            <template v-slot:activator>
              <v-list-item-content>
                <v-list-item-title>Become a Branch</v-list-item-title>
              </v-list-item-content>
            </template>
            <v-list-item
              v-for="(becomeBranch, i) in becomeBranchs"
              :key="i"
              @click=""
            >
              <v-list-item-title v-text="becomeBranch[0]"></v-list-item-title>
              <v-list-item-action>
                <v-icon v-text="becomeBranch[1]"></v-icon>
              </v-list-item-action>
            </v-list-item>
          </v-list-group>
        </v-list-group>
        
        <v-list-group
            sub-group
            no-action
          >
            <template v-slot:activator>
              <v-list-item-content>
                <v-list-item-title>Become a Partner</v-list-item-title>
              </v-list-item-content>
            </template>
            <v-list-item
              v-for="(becomePartner, i) in becomePartners"
              :key="i"
              @click=""
            >
              <v-list-item-title v-text="becomePartner[0]"></v-list-item-title>
              <v-list-item-action>
                <v-icon v-text="becomePartner[1]"></v-icon>
              </v-list-item-action>
            </v-list-item>
          </v-list-group>
        <!-- </v-list-group> -->
      
      <!-- <v-list-group
            sub-group
            no-action
          >
            <template v-slot:activator>
              <v-list-item-content>
                <v-list-item-title>Careers</v-list-item-title>
              </v-list-item-content>
            </template>
            <v-list-item
              v-for="(career, i) in careers"
              :key="i"
              @click=""
            >
              <v-list-item-title v-text="career[0]"></v-list-item-title>
              <v-list-item-action>
                <v-icon v-text="career[1]"></v-icon>
              </v-list-item-action>
            </v-list-item>
          </v-list-group>
        </v-list-group> -->
      </v-list>
    </v-card>
</template>

<script>
module.exports = {
    name: 'SalesForm',
    components : {

    },
    data: function () {
        return {
            becomeLOs: [
            ['Benefits', 'people_outline'],
            ['Get Started', 'settings'],
            ],
            becomeBranchs: [
            ['Benefits', 'people_outline'],
            ['Get Started', 'settings'],
            ],
            becomePartners: [
            ['Benefits', 'people_outline'],
            ['Get Started', 'settings'],
            ],
            careers: [
            ['Benefits', 'people_outline'],
            ['Get Started', 'settings'],
            ],
        };
    },
}